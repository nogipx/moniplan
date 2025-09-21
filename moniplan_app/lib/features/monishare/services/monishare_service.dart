import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:monishare/monishare_client.dart';
import 'package:rpc_dart_transports/rpc_dart_transports.dart';

class MonishareService {
  MonishareService();

  final _statusController = StreamController<bool>.broadcast();

  MoniShareClient? _client;
  RpcCallerEndpoint? _callerEndpoint;
  IRpcTransport? _callerTransport;
  bool _isStarted = false;
  bool _isStarting = false;

  // internal health-check state
  Timer? _healthTimer;
  bool _healthRunning = false;
  bool _reconnecting = false;

  bool get isConnected => _isStarted;

  Stream<bool> get statusStream => _statusController.stream;

  MoniShareClient get client {
    final value = _client;
    if (value == null) {
      throw StateError('MoniShareService is not started yet');
    }
    return value;
  }

  Future<void> ensureStarted() async {
    if (_isStarted) {
      return;
    }

    if (_isStarting) {
      // Дожидаемся завершения первоначального запуска
      while (_isStarting) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      return;
    }

    _isStarting = true;
    try {
      final localhost = '127.0.0.1';
      // final host = '192.168.1.127';
      final host = localhost;
      final port = 8081;

      IRpcTransport callerTransport;
      if (kIsWeb) {
        callerTransport = RpcWebSocketCallerTransport.connect(Uri.parse('ws://$host:$port'));
      } else {
        callerTransport = await RpcHttp2CallerTransport.connect(host: host, port: port);
      }

      _callerTransport = callerTransport;
      _callerEndpoint = RpcCallerEndpoint(transport: _callerTransport!);
      _callerEndpoint!.start();

      _client = MoniShareClient(_callerEndpoint!);
      _isStarted = true;
      _statusController.add(true);

      // start periodic health checks
      _startHealthChecks();
    } finally {
      _isStarting = false;
    }
  }

  void _startHealthChecks({Duration interval = const Duration(seconds: 5)}) {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(interval, (timer) async {
      if (_healthRunning) {
        return;
      }
      _healthRunning = true;
      try {
        final endpoint = _callerEndpoint;
        if (endpoint == null) {
          return;
        }

        final health = await endpoint.health();
        final healthy = health.isHealthy;

        if (!healthy) {
          _statusController.add(false);
          if (_reconnecting) {
            return;
          }
          _reconnecting = true;
          try {
            await endpoint.reconnect();
            _isStarted = true;
            _statusController.add(true);
          } on Object catch (_) {
            _isStarted = false;
            _statusController.add(false);
          } finally {
            _reconnecting = false;
          }
        } else {
          _statusController.add(true);
        }
      } finally {
        _healthRunning = false;
      }
    });
  }

  Future<void> dispose() async {
    _healthTimer?.cancel();
    _isStarted = false;
    try {
      await _callerEndpoint?.close();
    } on Object catch (_) {}
    try {
      await _callerTransport?.close();
    } on Object catch (_) {}
    await _statusController.close();
  }
}
