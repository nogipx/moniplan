part of 'rpc_health_bloc.dart';

@immutable
class RpcHealthState {
  const RpcHealthState({
    required this.status,
    this.interval,
    this.timeout,
    this.endpoint,
    this.ownsEndpoint = false,
    this.checking = false,
    this.reconnecting = false,
    this.lastHealthy,
    this.lastCheckedAt,
  });

  final RpcHealthStatus status;
  final RpcCallerEndpoint? endpoint;
  final bool ownsEndpoint;
  final bool checking;
  final bool reconnecting;
  final bool? lastHealthy;
  final DateTime? lastCheckedAt;
  final Duration? interval;
  final Duration? timeout;

  RpcHealthState copyWith({
    RpcHealthStatus? status,
    RpcCallerEndpoint? endpoint,
    bool? ownsEndpoint,
    bool? checking,
    bool? reconnecting,
    bool? lastHealthy,
    DateTime? lastCheckedAt,
    Duration? interval,
    Duration? timeout,
  }) {
    return RpcHealthState(
      status: status ?? this.status,
      endpoint: endpoint ?? this.endpoint,
      ownsEndpoint: ownsEndpoint ?? this.ownsEndpoint,
      checking: checking ?? this.checking,
      reconnecting: reconnecting ?? this.reconnecting,
      lastHealthy: lastHealthy ?? this.lastHealthy,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      interval: interval ?? this.interval,
      timeout: timeout ?? this.timeout,
    );
  }

  // Фабрики удобных состояний
  factory RpcHealthState.initial() {
    return const RpcHealthState(
      status: RpcHealthStatus.initial,
    );
  }

  factory RpcHealthState.connecting({
    required Duration interval,
    required Duration timeout,
    RpcCallerEndpoint? endpoint,
    bool ownsEndpoint = false,
  }) => RpcHealthState(
    status: RpcHealthStatus.connecting,
    endpoint: endpoint,
    ownsEndpoint: ownsEndpoint,
    interval: interval,
    timeout: timeout,
  );

  factory RpcHealthState.healthy(RpcHealthState base, {bool healthy = true}) => base.copyWith(
    status: RpcHealthStatus.healthy,
    lastHealthy: healthy,
    lastCheckedAt: DateTime.now(),
  );

  factory RpcHealthState.unhealthy(RpcHealthState base) => base.copyWith(
    status: RpcHealthStatus.unhealthy,
    lastHealthy: false,
    lastCheckedAt: DateTime.now(),
  );

  factory RpcHealthState.disconnected() => RpcHealthState.initial();
}

enum RpcHealthStatus { initial, connecting, healthy, unhealthy, disconnected }
