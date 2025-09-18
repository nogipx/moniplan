import 'package:rpc_dart/rpc_dart.dart';

/// Представляет пространство планнера.
class Space implements IRpcSerializable {
  Space({
    required this.plannerSpaceId,
    required this.createdAt,
    this.archivedAt,
  });

  final String plannerSpaceId;
  final DateTime createdAt;
  final DateTime? archivedAt;

  Space copyWith({DateTime? archivedAt}) => Space(
        plannerSpaceId: plannerSpaceId,
        createdAt: createdAt,
        archivedAt: archivedAt ?? this.archivedAt,
      );

  @override
  Map<String, dynamic> toJson() => {
        'plannerSpaceId': plannerSpaceId,
        'createdAt': createdAt.toIso8601String(),
        'archivedAt': archivedAt?.toIso8601String(),
      };

  static Space fromJson(Map<String, dynamic> json) => Space(
        plannerSpaceId: json['plannerSpaceId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        archivedAt: json['archivedAt'] == null
            ? null
            : DateTime.parse(json['archivedAt'] as String),
      );
}

/// Состояние инвайта.
enum InviteState {
  created,
  responded,
  finalized,
  expired,
}

InviteState inviteStateFromJson(String value) {
  return InviteState.values.firstWhere(
    (element) => element.name == value,
    orElse: () => InviteState.created,
  );
}

/// Зашифрованная операция.
class OperationRecord implements IRpcSerializable {
  OperationRecord({
    required this.plannerSpaceId,
    required this.opIdx,
    required this.tsServer,
    required this.actorPseudoId,
    required this.cipherLen,
    required this.cipherHash,
    required this.ciphertextB64,
  });

  final String plannerSpaceId;
  final int opIdx;
  final DateTime tsServer;
  final String actorPseudoId;
  final int cipherLen;
  final String cipherHash;
  final String ciphertextB64;

  @override
  Map<String, dynamic> toJson() => {
        'plannerSpaceId': plannerSpaceId,
        'opIdx': opIdx,
        'tsServer': tsServer.toIso8601String(),
        'actorPseudoId': actorPseudoId,
        'cipherLen': cipherLen,
        'cipherHash': cipherHash,
        'ciphertextB64': ciphertextB64,
      };

  static OperationRecord fromJson(Map<String, dynamic> json) => OperationRecord(
        plannerSpaceId: json['plannerSpaceId'] as String,
        opIdx: json['opIdx'] as int,
        tsServer: DateTime.parse(json['tsServer'] as String),
        actorPseudoId: json['actorPseudoId'] as String,
        cipherLen: json['cipherLen'] as int,
        cipherHash: json['cipherHash'] as String,
        ciphertextB64: json['ciphertextB64'] as String,
      );
}

/// Входная операция без серверных полей.
class OperationPayload implements IRpcSerializable {
  OperationPayload({
    required this.actorPseudoId,
    required this.cipherLen,
    required this.cipherHash,
    required this.ciphertextB64,
  });

  final String actorPseudoId;
  final int cipherLen;
  final String cipherHash;
  final String ciphertextB64;

  @override
  Map<String, dynamic> toJson() => {
        'actorPseudoId': actorPseudoId,
        'cipherLen': cipherLen,
        'cipherHash': cipherHash,
        'ciphertextB64': ciphertextB64,
      };

  static OperationPayload fromJson(Map<String, dynamic> json) =>
      OperationPayload(
        actorPseudoId: json['actorPseudoId'] as String,
        cipherLen: json['cipherLen'] as int,
        cipherHash: json['cipherHash'] as String,
        ciphertextB64: json['ciphertextB64'] as String,
      );
}

/// Уведомление о новых операциях в пространстве.
class OpsNotification implements IRpcSerializable {
  OpsNotification({
    required this.plannerSpaceId,
    required this.lastOpIdx,
    required this.batchSize,
  });

  final String plannerSpaceId;
  final int lastOpIdx;
  final int batchSize;

  @override
  Map<String, dynamic> toJson() => {
        'plannerSpaceId': plannerSpaceId,
        'lastOpIdx': lastOpIdx,
        'batchSize': batchSize,
      };

  static OpsNotification fromJson(Map<String, dynamic> json) => OpsNotification(
        plannerSpaceId: json['plannerSpaceId'] as String,
        lastOpIdx: json['lastOpIdx'] as int,
        batchSize: json['batchSize'] as int,
      );
}

/// DTO инвайта с публичными данными и зашифрованным конвертом.
class Invite implements IRpcSerializable {
  Invite({
    required this.inviteId,
    required this.createdAt,
    required this.state,
    this.expiresAt,
    this.ownerHandshakeB64,
    this.joinerHandshakeB64,
    this.finalHandshakeB64,
    this.encryptedEnvelopeB64,
  });

  final String inviteId;
  final DateTime createdAt;
  final InviteState state;
  final DateTime? expiresAt;
  final String? ownerHandshakeB64;
  final String? joinerHandshakeB64;
  final String? finalHandshakeB64;
  final String? encryptedEnvelopeB64;

  Invite copyWith({
    InviteState? state,
    DateTime? expiresAt,
    String? ownerHandshakeB64,
    String? joinerHandshakeB64,
    String? finalHandshakeB64,
    String? encryptedEnvelopeB64,
  }) {
    return Invite(
      inviteId: inviteId,
      createdAt: createdAt,
      state: state ?? this.state,
      expiresAt: expiresAt ?? this.expiresAt,
      ownerHandshakeB64: ownerHandshakeB64 ?? this.ownerHandshakeB64,
      joinerHandshakeB64: joinerHandshakeB64 ?? this.joinerHandshakeB64,
      finalHandshakeB64: finalHandshakeB64 ?? this.finalHandshakeB64,
      encryptedEnvelopeB64: encryptedEnvelopeB64 ?? this.encryptedEnvelopeB64,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'inviteId': inviteId,
        'createdAt': createdAt.toIso8601String(),
        'state': state.name,
        'expiresAt': expiresAt?.toIso8601String(),
        'ownerHandshakeB64': ownerHandshakeB64,
        'joinerHandshakeB64': joinerHandshakeB64,
        'finalHandshakeB64': finalHandshakeB64,
        'encryptedEnvelopeB64': encryptedEnvelopeB64,
      };

  static Invite fromJson(Map<String, dynamic> json) => Invite(
        inviteId: json['inviteId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        state: inviteStateFromJson(json['state'] as String),
        expiresAt: json['expiresAt'] == null
            ? null
            : DateTime.parse(json['expiresAt'] as String),
        ownerHandshakeB64: json['ownerHandshakeB64'] as String?,
        joinerHandshakeB64: json['joinerHandshakeB64'] as String?,
        finalHandshakeB64: json['finalHandshakeB64'] as String?,
        encryptedEnvelopeB64: json['encryptedEnvelopeB64'] as String?,
      );
}

/// Ошибка сервиса MoniShare.
class MoniShareException implements Exception {
  MoniShareException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'MoniShareException(code: $code, message: $message)';
}
