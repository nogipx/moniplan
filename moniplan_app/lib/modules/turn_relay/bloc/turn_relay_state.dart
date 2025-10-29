part of 'turn_relay_bloc.dart';

const Object _unset = Object();

enum TurnRelayStatus {
  initial,
  connectingRelay,
  relayReady,
  connectingPeer,
  peerReady,
  disconnecting,
}

@immutable
class TurnRelayState {
  const TurnRelayState({
    required this.status,
    this.peer,
    this.serverAddress,
    this.serverPort,
    this.peerAddress,
    this.peerPort,
    this.pendingConnectRequest,
    this.error,
    this.stackTrace,
    this.responderContracts = const [],
    this.options = const TurnRelayClientOptions(),
    this.isRequestingPeerConnection = false,
    this.chatMessages = const <TurnRelayChatMessage>[],
    this.isChatReady = false,
    this.isSendingChatMessage = false,
  });

  final TurnRelayStatus status;
  final RpcTurnRelayPeer? peer;
  final InternetAddress? serverAddress;
  final int? serverPort;
  final InternetAddress? peerAddress;
  final int? peerPort;
  final TurnConnectRequest? pendingConnectRequest;
  final Object? error;
  final StackTrace? stackTrace;
  final List<RpcResponderContract> responderContracts;
  final TurnRelayClientOptions options;
  final bool isRequestingPeerConnection;
  final List<TurnRelayChatMessage> chatMessages;
  final bool isChatReady;
  final bool isSendingChatMessage;

  bool get hasPeer => peer != null;

  factory TurnRelayState.initial() => const TurnRelayState(
        status: TurnRelayStatus.initial,
      );

  TurnRelayState copyWith({
    TurnRelayStatus? status,
    Object? peer = _unset,
    Object? serverAddress = _unset,
    Object? serverPort = _unset,
    Object? peerAddress = _unset,
    Object? peerPort = _unset,
    Object? pendingConnectRequest = _unset,
    Object? error = _unset,
    Object? stackTrace = _unset,
    List<RpcResponderContract>? responderContracts,
    TurnRelayClientOptions? options,
    bool? isRequestingPeerConnection,
    List<TurnRelayChatMessage>? chatMessages,
    bool? isChatReady,
    bool? isSendingChatMessage,
  }) {
    return TurnRelayState(
      status: status ?? this.status,
      peer: identical(peer, _unset) ? this.peer : peer as RpcTurnRelayPeer?,
      serverAddress: identical(serverAddress, _unset)
          ? this.serverAddress
          : serverAddress as InternetAddress?,
      serverPort: identical(serverPort, _unset)
          ? this.serverPort
          : serverPort as int?,
      peerAddress: identical(peerAddress, _unset)
          ? this.peerAddress
          : peerAddress as InternetAddress?,
      peerPort: identical(peerPort, _unset)
          ? this.peerPort
          : peerPort as int?,
      pendingConnectRequest: identical(pendingConnectRequest, _unset)
          ? this.pendingConnectRequest
          : pendingConnectRequest as TurnConnectRequest?,
      error: identical(error, _unset) ? this.error : error,
      stackTrace: identical(stackTrace, _unset)
          ? this.stackTrace
          : stackTrace as StackTrace?,
      responderContracts: responderContracts != null
          ? List<RpcResponderContract>.unmodifiable(responderContracts)
          : this.responderContracts,
      options: options ?? this.options,
      isRequestingPeerConnection:
          isRequestingPeerConnection ?? this.isRequestingPeerConnection,
      chatMessages: chatMessages != null
          ? List<TurnRelayChatMessage>.unmodifiable(chatMessages)
          : this.chatMessages,
      isChatReady: isChatReady ?? this.isChatReady,
      isSendingChatMessage:
          isSendingChatMessage ?? this.isSendingChatMessage,
    );
  }
}
