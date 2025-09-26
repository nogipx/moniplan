import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rpc_dart_transports/rpc_dart_transports.dart';
import 'package:universal_io/io.dart';
import 'package:uuid/uuid.dart';

import '../chat/turn_relay_chat_client.dart';
import '../chat/turn_relay_chat_contract.dart';
import '../chat/turn_relay_chat_responder.dart';

part 'turn_relay_event.dart';
part 'turn_relay_state.dart';

/// BLoC, управляющий жизненным циклом подключения к TURN relay и
/// отслеживающий поступающие запросы на подключение от других пиров.
class TurnRelayBloc extends Bloc<TurnRelayEvent, TurnRelayState> {
  TurnRelayBloc({TurnRelayState? initialState})
      : _log = RpcLogger('TurnRelayBloc'),
        _chatResponder = TurnRelayChatResponder(),
        super(initialState ?? TurnRelayState.initial()) {
    _chatMessageSubscription = _chatResponder.messages.listen(
      (message) => add(_TurnRelayChatMessageReceived(message)),
      onError: (Object error, StackTrace stackTrace) {
        add(_TurnRelayChatStreamFailed(error, stackTrace));
      },
    );

    on<TurnRelayConnectRequested>(_onConnectRequested);
    on<TurnRelayPeerConnectRequested>(_onPeerConnectRequested);
    on<TurnRelayPeerConnectionRequested>(_onPeerConnectionRequested);
    on<TurnRelayDisconnectRequested>(_onDisconnectRequested);
    on<TurnRelayClearFailure>(_onClearFailureRequested);
    on<TurnRelayConnectRequestConsumed>(_onConnectRequestConsumed);
    on<_TurnRelayConnectRequestReceived>(_onConnectRequestReceived);
    on<_TurnRelayConnectRequestStreamFailed>(_onConnectRequestStreamFailed);
    on<TurnRelayChatMessageSubmitted>(_onChatMessageSubmitted);
    on<_TurnRelayChatMessageReceived>(_onChatMessageReceived);
    on<_TurnRelayChatStreamFailed>(_onChatStreamFailed);
  }

  final RpcLogger _log;
  StreamSubscription<TurnConnectRequest>? _connectRequestSubscription;
  final TurnRelayChatResponder _chatResponder;
  StreamSubscription<TurnRelayChatMessage>? _chatMessageSubscription;
  TurnRelayChatClient? _chatClient;
  final Set<String> _deliveredChatMessageIds = <String>{};
  final Uuid _uuid = const Uuid();

  Future<void> _onConnectRequested(
    TurnRelayConnectRequested event,
    Emitter<TurnRelayState> emit,
  ) async {
    _log.info(
      'Connecting to TURN relay ${event.serverAddress.address}:${event.serverPort}',
    );

    await _closePeer();

    final options = event.options ?? state.options;
    _chatResponder.clearHistory();
    _chatClient = null;
    _deliveredChatMessageIds.clear();

    final responderContracts = <RpcResponderContract>[...event.responderContracts];
    if (!responderContracts.contains(_chatResponder)) {
      responderContracts.insert(0, _chatResponder);
    }

    emit(
      TurnRelayState.initial().copyWith(
        status: TurnRelayStatus.connectingRelay,
        serverAddress: event.serverAddress,
        serverPort: event.serverPort,
        responderContracts: responderContracts,
        options: options,
        error: null,
        stackTrace: null,
        chatMessages: const <TurnRelayChatMessage>[],
        isChatReady: false,
        isSendingChatMessage: false,
      ),
    );

    try {
      final peer = await RpcTurnRelayPeer.connectToRelay(
        serverAddress: event.serverAddress,
        serverPort: event.serverPort,
        responderContracts: responderContracts,
        options: options,
      );
      _log.info(
        'TURN relay connected. Relay endpoint: '
        '${peer.relayAddress.address}:${peer.relayPort}',
      );

      await _listenToPeer(peer);
      emit(
        state.copyWith(
          status: TurnRelayStatus.relayReady,
          peer: peer,
          isChatReady: false,
          chatMessages: const <TurnRelayChatMessage>[],
        ),
      );
    } on Object catch (error, stackTrace) {
      _log.error(
        'Failed to connect to TURN relay ${event.serverAddress.address}:${event.serverPort}',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: TurnRelayStatus.initial,
          peer: null,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _onPeerConnectRequested(
    TurnRelayPeerConnectRequested event,
    Emitter<TurnRelayState> emit,
  ) async {
    final peer = state.peer;
    if (peer == null) {
      final error = StateError('TURN relay peer is not connected');
      _log.warning(error.toString());
      emit(
        state.copyWith(
          error: error,
          stackTrace: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: TurnRelayStatus.connectingPeer,
        peerAddress: event.peerAddress,
        peerPort: event.peerPort,
        error: null,
        stackTrace: null,
      ),
    );

    try {
      await peer.connectPeer(
        peerAddress: event.peerAddress,
        peerPort: event.peerPort,
        logger: event.logger,
      );
      peer.callerEndpoint.start();
      _chatClient = TurnRelayChatClient(peer.callerEndpoint);
      _log.info(
        'Peer connected via TURN relay to '
        '${event.peerAddress.address}:${event.peerPort}',
      );
      emit(
        state.copyWith(
          status: TurnRelayStatus.peerReady,
          isChatReady: true,
          isSendingChatMessage: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      _log.error(
        'Failed to connect peer via TURN relay '
        '${event.peerAddress.address}:${event.peerPort}',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: TurnRelayStatus.relayReady,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _onPeerConnectionRequested(
    TurnRelayPeerConnectionRequested event,
    Emitter<TurnRelayState> emit,
  ) async {
    final peer = state.peer;
    if (peer == null) {
      final error = StateError('TURN relay peer is not connected');
      _log.warning(error.toString());
      emit(
        state.copyWith(
          error: error,
          stackTrace: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isRequestingPeerConnection: true,
        peerAddress: event.peerAddress,
        peerPort: event.peerPort,
        error: null,
        stackTrace: null,
      ),
    );

    try {
      await peer.requestPeerConnection(
        peerAddress: event.peerAddress,
        peerPort: event.peerPort,
        payload: event.payload,
      );
      _log.info(
        'Peer connection request sent to '
        '${event.peerAddress.address}:${event.peerPort}',
      );
      emit(
        state.copyWith(
          isRequestingPeerConnection: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      _log.error(
        'Failed to request TURN peer connection '
        '${event.peerAddress.address}:${event.peerPort}',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          isRequestingPeerConnection: false,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _onDisconnectRequested(
    TurnRelayDisconnectRequested event,
    Emitter<TurnRelayState> emit,
  ) async {
    if (state.peer == null) {
      emit(TurnRelayState.initial());
      return;
    }

    _log.info('Disconnecting from TURN relay');
    emit(
      state.copyWith(
        status: TurnRelayStatus.disconnecting,
        error: null,
        stackTrace: null,
        isChatReady: false,
        isSendingChatMessage: false,
        chatMessages: const <TurnRelayChatMessage>[],
      ),
    );

    await _closePeer();
    _chatClient = null;
    _deliveredChatMessageIds.clear();
    emit(
      state.copyWith(
        status: TurnRelayStatus.initial,
        peer: null,
        peerAddress: null,
        peerPort: null,
        pendingConnectRequest: null,
        isRequestingPeerConnection: false,
        isChatReady: false,
        isSendingChatMessage: false,
        chatMessages: const <TurnRelayChatMessage>[],
      ),
    );
  }

  void _onClearFailureRequested(
    TurnRelayClearFailure event,
    Emitter<TurnRelayState> emit,
  ) {
    emit(
      state.copyWith(
        error: null,
        stackTrace: null,
      ),
    );
  }

  void _onConnectRequestConsumed(
    TurnRelayConnectRequestConsumed event,
    Emitter<TurnRelayState> emit,
  ) {
    emit(
      state.copyWith(
        pendingConnectRequest: null,
      ),
    );
  }

  void _onConnectRequestReceived(
    _TurnRelayConnectRequestReceived event,
    Emitter<TurnRelayState> emit,
  ) {
    _log.info(
      'Incoming TURN connect request from '
      '${event.request.peerAddress.address}:${event.request.peerPort}',
    );
    emit(
      state.copyWith(
        pendingConnectRequest: event.request,
      ),
    );
  }

  void _onConnectRequestStreamFailed(
    _TurnRelayConnectRequestStreamFailed event,
    Emitter<TurnRelayState> emit,
  ) {
    _log.error(
      'TURN connect requests stream failed',
      error: event.error,
      stackTrace: event.stackTrace,
    );
    emit(
      state.copyWith(
        error: event.error,
        stackTrace: event.stackTrace,
      ),
    );
  }

  Future<void> _onChatMessageSubmitted(
    TurnRelayChatMessageSubmitted event,
    Emitter<TurnRelayState> emit,
  ) async {
    final client = _chatClient;
    if (client == null) {
      final error = StateError('TURN relay chat is not ready');
      _log.warning(error.toString());
      emit(
        state.copyWith(
          error: error,
          stackTrace: null,
        ),
      );
      return;
    }

    final messageText = event.text.trim();
    if (messageText.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        isSendingChatMessage: true,
        error: null,
        stackTrace: null,
      ),
    );

    final clientMessageId = _uuid.v4();
    try {
      final response = await client.sendMessage(
        authorId: event.authorId,
        text: messageText,
        clientMessageId: clientMessageId,
      );

      final responseMessage = response.message.id.isEmpty
          ? response.message.copyWith(id: clientMessageId)
          : response.message;
      final updatedMessages = _registerChatMessage(
        state.chatMessages,
        responseMessage,
        replaceExisting: true,
      );

      emit(
        state.copyWith(
          isSendingChatMessage: false,
          chatMessages: identical(updatedMessages, state.chatMessages)
              ? state.chatMessages
              : updatedMessages,
        ),
      );
    } on Object catch (error, stackTrace) {
      _log.error(
        'Failed to send chat message',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          isSendingChatMessage: false,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  void _onChatMessageReceived(
    _TurnRelayChatMessageReceived event,
    Emitter<TurnRelayState> emit,
  ) {
    final updatedMessages = _registerChatMessage(
      state.chatMessages,
      event.message,
    );

    if (!identical(updatedMessages, state.chatMessages)) {
      emit(
        state.copyWith(
          chatMessages: updatedMessages,
        ),
      );
    }
  }

  void _onChatStreamFailed(
    _TurnRelayChatStreamFailed event,
    Emitter<TurnRelayState> emit,
  ) {
    _log.error(
      'TURN relay chat stream failed',
      error: event.error,
      stackTrace: event.stackTrace,
    );
    emit(
      state.copyWith(
        error: event.error,
        stackTrace: event.stackTrace,
      ),
    );
  }

  Future<void> _listenToPeer(RpcTurnRelayPeer peer) async {
    await _connectRequestSubscription?.cancel();
    _connectRequestSubscription = peer.connectRequests.listen(
      (request) => add(_TurnRelayConnectRequestReceived(request)),
      onError: (Object error, StackTrace stackTrace) {
        add(_TurnRelayConnectRequestStreamFailed(error, stackTrace));
      },
    );
  }

  Future<void> _closePeer() async {
    await _connectRequestSubscription?.cancel();
    _connectRequestSubscription = null;

    final peer = state.peer;
    if (peer == null) {
      return;
    }

    try {
      await peer.close();
    } on Object catch (error, stackTrace) {
      _log.error(
        'Failed to close TURN relay peer',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> close() async {
    await _closePeer();
    await _chatMessageSubscription?.cancel();
    _chatResponder.dispose();
    await super.close();
  }

  List<TurnRelayChatMessage> _registerChatMessage(
    List<TurnRelayChatMessage> current,
    TurnRelayChatMessage incoming, {
    bool replaceExisting = false,
  }) {
    final messageId = incoming.id;
    if (messageId.isEmpty) {
      return current;
    }

    final alreadyDelivered = _deliveredChatMessageIds.contains(messageId);
    if (alreadyDelivered && !replaceExisting) {
      return current;
    }

    _deliveredChatMessageIds.add(messageId);
    final next = <TurnRelayChatMessage>[
      for (final message in current)
        if (message.id != messageId) message,
    ]
      ..add(incoming)
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

    return List<TurnRelayChatMessage>.unmodifiable(next);
  }
}
