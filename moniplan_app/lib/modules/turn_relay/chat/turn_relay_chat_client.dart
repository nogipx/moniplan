import 'package:rpc_dart/rpc_dart.dart';

import 'turn_relay_chat_contract.dart';

class TurnRelayChatClient extends RpcCallerContract {
  TurnRelayChatClient(RpcCallerEndpoint endpoint)
      : super(
          TurnRelayChatContract.serviceName,
          endpoint,
          dataTransferMode: RpcDataTransferMode.codec,
        );

  Future<TurnRelayChatSendResponse> sendMessage({
    required String authorId,
    required String text,
    String? clientMessageId,
    RpcContext? context,
  }) {
    return callUnary<TurnRelayChatSendRequest, TurnRelayChatSendResponse>(
      methodName: TurnRelayChatContract.methodSendMessage,
      request: TurnRelayChatSendRequest(
        authorId: authorId,
        text: text,
        clientMessageId: clientMessageId,
      ),
      requestCodec: TurnRelayChatContract.sendRequestCodec,
      responseCodec: TurnRelayChatContract.sendResponseCodec,
      context: context,
    );
  }

  Stream<TurnRelayChatMessage> subscribe({
    bool includeHistory = true,
    RpcContext? context,
  }) {
    return callServerStream<TurnRelayChatSubscribeRequest, TurnRelayChatMessage>(
      methodName: TurnRelayChatContract.methodSubscribeMessages,
      request: TurnRelayChatSubscribeRequest(includeHistory: includeHistory),
      requestCodec: TurnRelayChatContract.subscribeRequestCodec,
      responseCodec: TurnRelayChatContract.messageCodec,
      context: context,
    );
  }
}
