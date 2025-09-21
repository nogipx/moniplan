part of 'rpc_health_bloc.dart';

class RpcHealthInitialData {
  final RpcCallerEndpoint? endpoint;
  final String? host;
  final int? port;

  const RpcHealthInitialData({
    this.endpoint,
    this.host,
    this.port,
  });
}

@immutable
abstract class RpcHealthEvent {
  const RpcHealthEvent();
}

/// Запустить мониторинг состояния endpoint.
///
/// Параметры:
/// - endpoint: готовый RpcCallerEndpoint — если указан, BLoC будет использовать его и не будет создавать собственный транспорт.
/// - transport: если указан транспорт, BLoC использует его для создания RpcCallerEndpoint.
/// - host/port: если указан host (и порт), BLoC создаст транспорт (HTTP2 или WebSocket) и endpoint сам.
/// - interval: интервал проверок здоровья.
/// - timeout: таймаут на ответ от сервера.
class RpcHealthStart extends RpcHealthEvent {
  const RpcHealthStart({
    this.interval,
    this.timeout,
    this.data,
  });

  final RpcHealthInitialData? data;
  final Duration? interval;
  final Duration? timeout;
}

class RpcHealthStop extends RpcHealthEvent {
  const RpcHealthStop();
}

class _RpcHealthCheck extends RpcHealthEvent {
  const _RpcHealthCheck();
}

class _RpcHealthReconnectRequested extends RpcHealthEvent {
  const _RpcHealthReconnectRequested();
}
