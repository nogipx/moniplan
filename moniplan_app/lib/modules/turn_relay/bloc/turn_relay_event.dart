part of 'turn_relay_bloc.dart';

@immutable
abstract class TurnRelayEvent {
  const TurnRelayEvent();
}

class TurnRelayConnectRequested extends TurnRelayEvent {
  TurnRelayConnectRequested({
    required this.serverAddress,
    required this.serverPort,
    Iterable<RpcResponderContract> responderContracts = const [],
    this.options,
  }) : responderContracts =
            List<RpcResponderContract>.unmodifiable(responderContracts);

  final InternetAddress serverAddress;
  final int serverPort;
  final List<RpcResponderContract> responderContracts;
  final TurnRelayClientOptions? options;
}

class TurnRelayPeerConnectRequested extends TurnRelayEvent {
  const TurnRelayPeerConnectRequested({
    required this.peerAddress,
    required this.peerPort,
    this.logger,
  });

  final InternetAddress peerAddress;
  final int peerPort;
  final RpcLogger? logger;
}

class TurnRelayPeerConnectionRequested extends TurnRelayEvent {
  const TurnRelayPeerConnectionRequested({
    required this.peerAddress,
    required this.peerPort,
    this.payload,
  });

  final InternetAddress peerAddress;
  final int peerPort;
  final Uint8List? payload;
}

class TurnRelayDisconnectRequested extends TurnRelayEvent {
  const TurnRelayDisconnectRequested();
}

class TurnRelayClearFailure extends TurnRelayEvent {
  const TurnRelayClearFailure();
}

class TurnRelayConnectRequestConsumed extends TurnRelayEvent {
  const TurnRelayConnectRequestConsumed();
}

class _TurnRelayConnectRequestReceived extends TurnRelayEvent {
  const _TurnRelayConnectRequestReceived(this.request);

  final TurnConnectRequest request;
}

class _TurnRelayConnectRequestStreamFailed extends TurnRelayEvent {
  const _TurnRelayConnectRequestStreamFailed(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}
