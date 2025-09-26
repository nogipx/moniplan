import 'dart:async';

import 'package:rpc_dart/rpc_dart.dart';
import 'package:uuid/uuid.dart';

import 'turn_relay_chat_contract.dart';

class TurnRelayChatResponder extends RpcResponderContract {
  TurnRelayChatResponder({
    StreamController<TurnRelayChatMessage>? controller,
    DateTime Function()? clock,
    Uuid? uuid,
  })  : _messagesController =
            controller ?? StreamController<TurnRelayChatMessage>.broadcast(),
        _clock = clock ?? DateTime.now,
        _uuid = uuid ?? const Uuid(),
        _history = <TurnRelayChatMessage>[],
        super(
          TurnRelayChatContract.serviceName,
          dataTransferMode: RpcDataTransferMode.codec,
        );

  final StreamController<TurnRelayChatMessage> _messagesController;
  final DateTime Function() _clock;
  final Uuid _uuid;
  final List<TurnRelayChatMessage> _history;

  Stream<TurnRelayChatMessage> get messages => _messagesController.stream;

  @override
  void setup() {
    addUnaryMethod<TurnRelayChatSendRequest, TurnRelayChatSendResponse>(
      methodName: TurnRelayChatContract.methodSendMessage,
      handler: _handleSendMessage,
      requestCodec: TurnRelayChatContract.sendRequestCodec,
      responseCodec: TurnRelayChatContract.sendResponseCodec,
    );

    addServerStreamMethod<TurnRelayChatSubscribeRequest, TurnRelayChatMessage>(
      methodName: TurnRelayChatContract.methodSubscribeMessages,
      handler: _handleSubscribe,
      requestCodec: TurnRelayChatContract.subscribeRequestCodec,
      responseCodec: TurnRelayChatContract.messageCodec,
    );
  }

  Future<TurnRelayChatSendResponse> _handleSendMessage(
    TurnRelayChatSendRequest request, {
    RpcContext? context,
  }) async {
    final messageId = request.clientMessageId ?? _uuid.v4();
    final timestamp = _clock().toUtc();
    final message = TurnRelayChatMessage(
      id: messageId,
      authorId: request.authorId,
      text: request.text,
      sentAt: timestamp,
    );

    _history.add(message);
    if (!_messagesController.isClosed) {
      _messagesController.add(message);
    }

    return TurnRelayChatSendResponse(message: message);
  }

  Stream<TurnRelayChatMessage> _handleSubscribe(
    TurnRelayChatSubscribeRequest request, {
    RpcContext? context,
  }) async* {
    if (request.includeHistory) {
      for (final message in _history) {
        yield message;
      }
    }

    yield* messages;
  }

  void clearHistory() {
    _history.clear();
  }

  @override
  void dispose() {
    if (!_messagesController.isClosed) {
      _messagesController.close();
    }
    super.dispose();
  }
}
