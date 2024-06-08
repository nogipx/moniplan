typedef AppLogFactory = AppLog Function(String loggerName);

abstract interface class AppLog {
  /// Метод для логирования бизнес-событий.
  ///
  /// Всегда отправляется в Sentry.
  void business(Object? msg);

  /// Метод для логирования важных отладочных данных.
  /// Можно опционально отправлять в Sentry.
  void debug(Object? msg, {bool trace = false, bool sentry = false});

  /// Метод для логирования отладочной информации.
  ///
  /// Предназначен для отладки каких-либо участков,
  /// которые производят много логов и нагрузят Sentry.
  /// Например, состояние анимации или состояние скрола.
  ///
  /// Никогда не отправляется в Sentry
  void trace(Object? msg, {bool trace = false});

  /// Метод для логирования предупреждений.
  ///
  /// Можно опционально отправлять в Sentry.
  void warning(Object? msg, {bool trace = false, bool sentry = false});

  /// Метод для логирования ожидаемых ошибок.
  ///
  /// Всегда отправляется в Sentry.
  void error(Object? msg, {Object? error, StackTrace? trace});

  /// Метод для логирования критичных или неожиданных ошибок.
  ///
  /// Всегда отправляется в Sentry.
  void critical(Object? msg, {Object? error, StackTrace? trace});

  /// Метод для логирования ошибок сетевых запросов.
  ///
  /// Всегда отправляется в Sentry, кроме healthcheck запросов.
  void network(
    Object? msg, {
    Object? error,
    StackTrace? trace,
    String? method,
    int? statusCode,
    String? url,
  });

  static const tagSeparator = '|_@_|';

  static late final AppLogFactory? _factory;

  // ignore: avoid_setters_without_getters
  static set factory(AppLogFactory newFactory) {
    _factory = newFactory;
  }

  factory AppLog(String loggerName) {
    if (_factory == null) {
      throw UnimplementedError('Logger factory not setted.');
    }
    return _factory!(loggerName);
  }

  factory AppLog.get(String loggerName) {
    return AppLog(loggerName);
  }
}
