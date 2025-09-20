import 'dart:async';

import 'package:monishare/monishare_client.dart';
import 'package:monishare/monishare_responder.dart';
import 'package:rpc_dart/rpc_dart.dart';

class MonishareService {
  MonishareService();

  final _statusController = StreamController<bool>.broadcast();

  MoniShareClient? _client;
  RpcCallerEndpoint? _callerEndpoint;
  RpcResponderEndpoint? _responderEndpoint;
  IRpcTransport? _callerTransport;
  IRpcTransport? _responderTransport;
  bool _isStarted = false;
  bool _isStarting = false;

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
      final pair = RpcInMemoryTransport.pair();
      _callerTransport = pair.$1;
      _responderTransport = pair.$2;

      _callerEndpoint = RpcCallerEndpoint(transport: _callerTransport!);
      _responderEndpoint = RpcResponderEndpoint(transport: _responderTransport!);

      final responder = MoniShareResponder();
      _responderEndpoint!.registerServiceContract(responder);

      _responderEndpoint!.start();
      _callerEndpoint!.start();

      _client = MoniShareClient(_callerEndpoint!);
      _isStarted = true;
      _statusController.add(true);
    } finally {
      _isStarting = false;
    }
  }

  Future<void> dispose() async {
    _isStarted = false;
    await _callerEndpoint?.close();
    await _responderEndpoint?.close();
    await _callerTransport?.close();
    await _responderTransport?.close();
    await _statusController.close();
  }
}
