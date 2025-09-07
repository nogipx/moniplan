import 'dart:developer' as dev;

import 'package:moniplan_app/domain/lib/moniplan_domain.dart';

/// A console-based implementation of the AppLog interface that provides structured logging
/// with support for different log levels, network operations, and stack trace formatting.
///
/// Features:
/// - Multiple log levels (debug, network, warning, error, critical, business, trace)
/// - Automatic caller location detection
/// - Network operation logging with request/response/error type detection
/// - Stack trace formatting with line truncation
/// - Timestamp and emoji indicators for better visual distinction
///
/// Example usage:
/// ```dart
/// final log = ConsoleAppLog('MyComponent');
/// log.debug('Initializing component');
/// log.network('Sending request', method: 'POST', url: '/api/data');
/// ```
final class ConsoleAppLog implements AppLog {
  /// The name of the logger component, used to identify the source of log entries
  final String name;
  final Set<String>? skipPathContainsPaths;
  final int? skipFrames;

  ConsoleAppLog._(this.name, {this.skipPathContainsPaths, this.skipFrames});

  /// Creates a new instance of ConsoleAppLog with the specified component name
  factory ConsoleAppLog(String name, {Set<String>? skipPathContainsPaths, int? skipFrames}) =>
      ConsoleAppLog._(
        name,
        skipPathContainsPaths: {'consoleapplog', ...skipPathContainsPaths ?? {}},
        skipFrames: skipFrames,
      );

  /// Mapping of log levels to their abbreviated symbols
  static const _symbols = {
    'DEBUG': 'DBG',
    'NETWORK': 'NET',
    'WARNING': 'WRN',
    'ERROR': 'ERR',
    'CRITICAL': 'CRT',
    'BUSINESS': 'BIZ',
    'TRACE': 'TRC',
  };

  /// Mapping of log levels to their corresponding emoji indicators
  static const _emojis = {
    'DEBUG': '🟦',
    'NETWORK': '🌐',
    'WARNING': '🔶',
    'ERROR': '⭕',
    'CRITICAL': '⛔‼️',
    'BUSINESS': '📋',
    'TRACE': '🔘',
  };

  /// Regular expression for extracting file path and line number from stack traces
  static final _locationRegex = RegExp(r'(?:package:)?([^\s]+):(\d+)');

  /// Generates a formatted timestamp string in the format HH:mm:ss.SSS
  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  /// Attempts to find the caller's location from the stack trace
  ///
  /// [skipFrames] The number of frames to skip in the stack trace
  /// Returns a string in the format "file:line" or empty string if location cannot be determined
  String _findCallerLocation([int? skipFrames, StackTrace? trace]) {
    try {
      final traceStr = (trace ?? StackTrace.current).toString().split('\n');
      final filteredFrames =
          skipFrames != null && skipFrames >= 0 ? traceStr.skip(skipFrames).toList() : traceStr;

      for (final line in filteredFrames) {
        final match = _locationRegex.firstMatch(line);
        if (match != null) {
          final path = match.group(1)?.replaceFirst('(', '');
          final lineNum = match.group(2);
          if (path != null && lineNum != null) {
            if (skipPathContainsPaths?.any((e) => path.contains(e.toLowerCase())) ?? false) {
              continue;
            }
            return '$path:$lineNum';
          }
        }
        break;
      }
    } catch (e) {
      // Игнорируем ошибки парсинга
    }
    return '';
  }

  /// Formats a log message with all its components
  ///
  /// Parameters:
  /// - [level] The log level (DEBUG, NETWORK, etc.)
  /// - [msg] The main message to log
  /// - [error] Optional error object
  /// - [trace] Optional stack trace
  /// - [method] Optional HTTP method for network logs
  /// - [statusCode] Optional HTTP status code for network logs
  /// - [url] Optional URL for network logs
  /// - [skipFrames] Number of frames to skip when determining caller location
  /// - [networkType] Optional network operation type for specialized network logging
  String _formatMessage(
    String level,
    Object? msg, {
    Object? error,
    StackTrace? trace,
    String? method,
    int? statusCode,
    String? url,
    _NetworkLogType? networkType,
  }) {
    final timestamp = _getTimestamp();
    final symbol = _symbols[level] ?? '???';
    final emoji = networkType?.emoji ?? _emojis[level] ?? '❓';

    // Получаем локацию только если включен debug режим
    final location = _findCallerLocation(skipFrames, trace);

    final buffer = StringBuffer('\n');

    // Добавляем локацию только если она определена
    if (location.isNotEmpty) {
      buffer.write(location);
    }

    buffer.write('\n── ');
    buffer.write('$timestamp | $emoji $symbol | $name');

    // Собираем дополнительную информацию
    if (url != null || method != null || statusCode != null) {
      buffer.write('\n   ');
      if (statusCode != null) buffer.write('($statusCode) ');
      if (method != null) buffer.write('$method ');
      if (url != null) buffer.write(url);
    }

    buffer.write('\n   $msg');

    // Добавляем ошибку если есть
    if (error != null) {
      buffer.write('\n   Error: $error');
    }

    // Форматируем стек если есть
    if (trace != null) {
      final lines = trace.toString().split('\n');
      // Берем только первые 3 строки стека для компактности
      buffer.write('\n   Stack:');
      for (var i = 0; i < lines.length && i < 3; i++) {
        final line = lines[i].trim();
        // Обрезаем длинные строки
        if (line.length > 70) {
          buffer.write('\n     ...${line.substring(line.length - 67)}');
        } else {
          buffer.write('\n     $line');
        }
      }
      if (lines.length > 3) {
        buffer.write('\n     ...(+${lines.length - 3})');
      }
    }

    return buffer.toString();
  }

  @override
  void business(Object? msg, {bool saveToFile = true}) {
    dev.log(_formatMessage('BUSINESS', msg), level: 800, name: '-');
  }

  @override
  void critical(Object? msg, {Object? error, StackTrace? trace, bool saveToFile = true}) {
    dev.log(
      _formatMessage('CRITICAL', msg, error: error, trace: trace),
      error: error,
      stackTrace: trace,
      level: 1000,
      name: '-',
    );
  }

  @override
  void debug(Object? msg, {bool sentry = false, bool trace = false}) {
    dev.log(_formatMessage('DEBUG', msg), level: 500, name: '-');
  }

  @override
  void error(Object? msg, {Object? error, StackTrace? trace, bool saveToFile = true}) {
    dev.log(
      _formatMessage('ERROR', msg, error: error, trace: trace),
      error: error,
      stackTrace: trace,
      level: 900,
      name: '-',
    );
  }

  @override
  void network(
    Object? msg, {
    Object? error,
    StackTrace? trace,
    String? method,
    int? statusCode,
    String? url,
  }) {
    // Автоматически определяем тип на основе параметров
    final type =
        error != null
            ? _NetworkLogType.error
            : statusCode != null
            ? _NetworkLogType.response
            : _NetworkLogType.request;

    dev.log(
      _formatMessage(
        'NETWORK',
        msg,
        error: error,
        trace: trace,
        method: method,
        statusCode: statusCode,
        url: url,
        networkType: type,
      ),
      error: error,
      stackTrace: trace,
      level: 700,
      name: '-',
    );
  }

  @override
  void trace(Object? msg, {bool trace = false, bool saveToFile = true}) {
    dev.log(_formatMessage('TRACE', msg), level: 400, name: '-');
  }

  @override
  void warning(Object? msg, {bool sentry = false, bool trace = false}) {
    dev.log(_formatMessage('WARNING', msg), level: 600, name: '-');
  }

  String getLocation([StackTrace? trace]) {
    return _findCallerLocation(skipFrames, trace);
  }
}

/// Represents different types of network operations in logs
///
/// Each type has an associated emoji and description for visual identification
/// in the log output.
enum _NetworkLogType {
  /// Outgoing network requests
  request('🔼 (Request)'),

  /// Incoming network responses
  response('🔽 (Response)'),

  /// Network operation errors
  error('❌ (Error)');

  /// The emoji and description used in log formatting
  final String emoji;
  const _NetworkLogType(this.emoji);
}
