import 'package:meta/meta.dart';
import 'package:rpc_dart/rpc_dart.dart';

@immutable
class TurnRelayChatMessage implements IRpcSerializable {
  const TurnRelayChatMessage({
    required this.id,
    required this.authorId,
    required this.text,
    required this.sentAt,
  });

  factory TurnRelayChatMessage.fromJson(Map<String, dynamic> json) {
    return TurnRelayChatMessage(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      text: json['text'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String).toUtc(),
    );
  }

  final String id;
  final String authorId;
  final String text;
  final DateTime sentAt;

  TurnRelayChatMessage copyWith({
    String? id,
    String? authorId,
    String? text,
    DateTime? sentAt,
  }) {
    return TurnRelayChatMessage(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'text': text,
        'sentAt': sentAt.toIso8601String(),
      };
}

@immutable
class TurnRelayChatSendRequest implements IRpcSerializable {
  const TurnRelayChatSendRequest({
    required this.authorId,
    required this.text,
    this.clientMessageId,
  });

  factory TurnRelayChatSendRequest.fromJson(Map<String, dynamic> json) {
    return TurnRelayChatSendRequest(
      authorId: json['authorId'] as String,
      text: json['text'] as String,
      clientMessageId: json['clientMessageId'] as String?,
    );
  }

  final String authorId;
  final String text;
  final String? clientMessageId;

  @override
  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'text': text,
        if (clientMessageId != null) 'clientMessageId': clientMessageId,
      };
}

@immutable
class TurnRelayChatSendResponse implements IRpcSerializable {
  const TurnRelayChatSendResponse({required this.message});

  factory TurnRelayChatSendResponse.fromJson(Map<String, dynamic> json) {
    final messageJson = Map<String, dynamic>.from(json['message'] as Map);
    return TurnRelayChatSendResponse(
      message: TurnRelayChatMessage.fromJson(messageJson),
    );
  }

  final TurnRelayChatMessage message;

  @override
  Map<String, dynamic> toJson() => {
        'message': message.toJson(),
      };
}

@immutable
class TurnRelayChatSubscribeRequest implements IRpcSerializable {
  const TurnRelayChatSubscribeRequest({this.includeHistory = true});

  factory TurnRelayChatSubscribeRequest.fromJson(Map<String, dynamic> json) {
    return TurnRelayChatSubscribeRequest(
      includeHistory: (json['includeHistory'] as bool?) ?? true,
    );
  }

  final bool includeHistory;

  @override
  Map<String, dynamic> toJson() => {
        'includeHistory': includeHistory,
      };
}

abstract final class TurnRelayChatContract {
  static const serviceName = 'turnRelayChat.v1';

  static const methodSendMessage = 'chat.sendMessage';
  static const methodSubscribeMessages = 'chat.subscribe';

  static final messageCodec =
      RpcCodec<TurnRelayChatMessage>(TurnRelayChatMessage.fromJson);
  static final sendRequestCodec =
      RpcCodec<TurnRelayChatSendRequest>(TurnRelayChatSendRequest.fromJson);
  static final sendResponseCodec =
      RpcCodec<TurnRelayChatSendResponse>(TurnRelayChatSendResponse.fromJson);
  static final subscribeRequestCodec = RpcCodec<TurnRelayChatSubscribeRequest>(
    TurnRelayChatSubscribeRequest.fromJson,
  );
}
