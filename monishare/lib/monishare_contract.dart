import 'package:rpc_dart/rpc_dart.dart';

import 'models.dart';

class SpacesRegisterRequest implements IRpcSerializable {
  const SpacesRegisterRequest({this.plannerSpaceIdHint});

  final String? plannerSpaceIdHint;

  @override
  Map<String, dynamic> toJson() => {
        if (plannerSpaceIdHint != null)
          'plannerSpaceIdHint': plannerSpaceIdHint,
      };

  static SpacesRegisterRequest fromJson(Map<String, dynamic> json) =>
      SpacesRegisterRequest(
        plannerSpaceIdHint: json['plannerSpaceIdHint'] as String?,
      );
}

class SpacesRegisterResponse implements IRpcSerializable {
  const SpacesRegisterResponse({required this.space});

  final Space space;

  @override
  Map<String, dynamic> toJson() => {
        'space': space.toJson(),
      };

  static SpacesRegisterResponse fromJson(Map<String, dynamic> json) =>
      SpacesRegisterResponse(
        space: Space.fromJson(
          Map<String, dynamic>.from(json['space'] as Map),
        ),
      );
}

class SpacesArchiveRequest implements IRpcSerializable {
  const SpacesArchiveRequest({required this.plannerSpaceId});

  final String plannerSpaceId;

  @override
  Map<String, dynamic> toJson() => {
        'plannerSpaceId': plannerSpaceId,
      };

  static SpacesArchiveRequest fromJson(Map<String, dynamic> json) =>
      SpacesArchiveRequest(
        plannerSpaceId: json['plannerSpaceId'] as String,
      );
}

class SpacesArchiveResponse implements IRpcSerializable {
  const SpacesArchiveResponse({required this.space});

  final Space space;

  @override
  Map<String, dynamic> toJson() => {
        'space': space.toJson(),
      };

  static SpacesArchiveResponse fromJson(Map<String, dynamic> json) =>
      SpacesArchiveResponse(
        space: Space.fromJson(
          Map<String, dynamic>.from(json['space'] as Map),
        ),
      );
}

class OpsAppendRequest implements IRpcSerializable {
  const OpsAppendRequest({
    required this.plannerSpaceId,
    required this.operations,
  });

  final String plannerSpaceId;
  final List<OperationPayload> operations;

  @override
  Map<String, dynamic> toJson() => {
        'plannerSpaceId': plannerSpaceId,
        'operations': operations.map((e) => e.toJson()).toList(),
      };

  static OpsAppendRequest fromJson(Map<String, dynamic> json) =>
      OpsAppendRequest(
        plannerSpaceId: json['plannerSpaceId'] as String,
        operations: (json['operations'] as List<dynamic>)
            .map(
              (e) => OperationPayload.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
      );
}

class OpsAppendResponse implements IRpcSerializable {
  const OpsAppendResponse({
    required this.plannerSpaceId,
    required this.lastOpIdx,
    required this.appendedCount,
  });

  final String plannerSpaceId;
  final int lastOpIdx;
  final int appendedCount;

  @override
  Map<String, dynamic> toJson() => {
        'plannerSpaceId': plannerSpaceId,
        'lastOpIdx': lastOpIdx,
        'appendedCount': appendedCount,
      };

  static OpsAppendResponse fromJson(Map<String, dynamic> json) =>
      OpsAppendResponse(
        plannerSpaceId: json['plannerSpaceId'] as String,
        lastOpIdx: json['lastOpIdx'] as int,
        appendedCount: json['appendedCount'] as int,
      );
}

class OpsPullRequest implements IRpcSerializable {
  const OpsPullRequest({
    required this.plannerSpaceId,
    required this.sinceOpIdx,
    this.limit,
  });

  final String plannerSpaceId;
  final int sinceOpIdx;
  final int? limit;

  @override
  Map<String, dynamic> toJson() => {
        'plannerSpaceId': plannerSpaceId,
        'sinceOpIdx': sinceOpIdx,
        if (limit != null) 'limit': limit,
      };

  static OpsPullRequest fromJson(Map<String, dynamic> json) => OpsPullRequest(
        plannerSpaceId: json['plannerSpaceId'] as String,
        sinceOpIdx: json['sinceOpIdx'] as int,
        limit: json['limit'] as int?,
      );
}

class OpsPullResponse implements IRpcSerializable {
  const OpsPullResponse({required this.operations});

  final List<OperationRecord> operations;

  @override
  Map<String, dynamic> toJson() => {
        'operations': operations.map((e) => e.toJson()).toList(),
      };

  static OpsPullResponse fromJson(Map<String, dynamic> json) => OpsPullResponse(
        operations: (json['operations'] as List<dynamic>)
            .map(
              (e) => OperationRecord.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
      );
}

class OpsSubscribeRequest implements IRpcSerializable {
  const OpsSubscribeRequest({required this.plannerSpaceId});

  final String plannerSpaceId;

  @override
  Map<String, dynamic> toJson() => {
        'plannerSpaceId': plannerSpaceId,
      };

  static OpsSubscribeRequest fromJson(Map<String, dynamic> json) =>
      OpsSubscribeRequest(
        plannerSpaceId: json['plannerSpaceId'] as String,
      );
}

class InvitesCreateRequest implements IRpcSerializable {
  const InvitesCreateRequest({
    required this.plannerSpaceId,
    required this.ownerHandshakeB64,
    this.expiresAt,
    this.ttlSeconds,
  });

  final String plannerSpaceId;
  final String ownerHandshakeB64;
  final DateTime? expiresAt;
  final int? ttlSeconds;

  @override
  Map<String, dynamic> toJson() => {
        'plannerSpaceId': plannerSpaceId,
        'ownerHandshakeB64': ownerHandshakeB64,
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
        if (ttlSeconds != null) 'ttlSeconds': ttlSeconds,
      };

  static InvitesCreateRequest fromJson(Map<String, dynamic> json) =>
      InvitesCreateRequest(
        plannerSpaceId: json['plannerSpaceId'] as String,
        ownerHandshakeB64: json['ownerHandshakeB64'] as String,
        expiresAt: json['expiresAt'] == null
            ? null
            : DateTime.parse(json['expiresAt'] as String),
        ttlSeconds: json['ttlSeconds'] as int?,
      );
}

class InvitesMutationResponse implements IRpcSerializable {
  const InvitesMutationResponse({required this.invite});

  final Invite invite;

  @override
  Map<String, dynamic> toJson() => {
        'invite': invite.toJson(),
      };

  static InvitesMutationResponse fromJson(Map<String, dynamic> json) =>
      InvitesMutationResponse(
        invite: Invite.fromJson(
          Map<String, dynamic>.from(json['invite'] as Map),
        ),
      );
}

class InvitesRespondRequest implements IRpcSerializable {
  const InvitesRespondRequest({
    required this.inviteId,
    required this.joinerHandshakeB64,
  });

  final String inviteId;
  final String joinerHandshakeB64;

  @override
  Map<String, dynamic> toJson() => {
        'inviteId': inviteId,
        'joinerHandshakeB64': joinerHandshakeB64,
      };

  static InvitesRespondRequest fromJson(Map<String, dynamic> json) =>
      InvitesRespondRequest(
        inviteId: json['inviteId'] as String,
        joinerHandshakeB64: json['joinerHandshakeB64'] as String,
      );
}

class InvitesFinalizeRequest implements IRpcSerializable {
  const InvitesFinalizeRequest({
    required this.inviteId,
    required this.finalHandshakeB64,
    required this.encryptedEnvelopeB64,
  });

  final String inviteId;
  final String finalHandshakeB64;
  final String encryptedEnvelopeB64;

  @override
  Map<String, dynamic> toJson() => {
        'inviteId': inviteId,
        'finalHandshakeB64': finalHandshakeB64,
        'encryptedEnvelopeB64': encryptedEnvelopeB64,
      };

  static InvitesFinalizeRequest fromJson(Map<String, dynamic> json) =>
      InvitesFinalizeRequest(
        inviteId: json['inviteId'] as String,
        finalHandshakeB64: json['finalHandshakeB64'] as String,
        encryptedEnvelopeB64: json['encryptedEnvelopeB64'] as String,
      );
}

class InvitesFetchRequest implements IRpcSerializable {
  const InvitesFetchRequest({required this.inviteId});

  final String inviteId;

  @override
  Map<String, dynamic> toJson() => {
        'inviteId': inviteId,
      };

  static InvitesFetchRequest fromJson(Map<String, dynamic> json) =>
      InvitesFetchRequest(
        inviteId: json['inviteId'] as String,
      );
}

class InvitesFetchResponse implements IRpcSerializable {
  const InvitesFetchResponse({this.invite});

  final Invite? invite;

  @override
  Map<String, dynamic> toJson() => {
        if (invite != null) 'invite': invite!.toJson(),
      };

  static InvitesFetchResponse fromJson(Map<String, dynamic> json) =>
      InvitesFetchResponse(
        invite: json['invite'] == null
            ? null
            : Invite.fromJson(
                Map<String, dynamic>.from(json['invite'] as Map),
              ),
      );
}

abstract final class MoniShareContract {
  static const serviceName = 'monishare.v1';

  static const methodSpacesRegister = 'spaces.register';
  static const methodSpacesArchive = 'spaces.archive';
  static const methodOpsAppend = 'ops.append';
  static const methodOpsPull = 'ops.pull';
  static const methodOpsSubscribe = 'ops.subscribe';
  static const methodInvitesCreate = 'invites.create';
  static const methodInvitesRespond = 'invites.respond';
  static const methodInvitesFinalize = 'invites.finalize';
  static const methodInvitesFetch = 'invites.fetch';

  static final spacesRegisterRequestCodec =
      RpcCodec<SpacesRegisterRequest>(SpacesRegisterRequest.fromJson);
  static final spacesRegisterResponseCodec =
      RpcCodec<SpacesRegisterResponse>(SpacesRegisterResponse.fromJson);
  static final spacesArchiveRequestCodec =
      RpcCodec<SpacesArchiveRequest>(SpacesArchiveRequest.fromJson);
  static final spacesArchiveResponseCodec =
      RpcCodec<SpacesArchiveResponse>(SpacesArchiveResponse.fromJson);
  static final opsAppendRequestCodec =
      RpcCodec<OpsAppendRequest>(OpsAppendRequest.fromJson);
  static final opsAppendResponseCodec =
      RpcCodec<OpsAppendResponse>(OpsAppendResponse.fromJson);
  static final opsPullRequestCodec =
      RpcCodec<OpsPullRequest>(OpsPullRequest.fromJson);
  static final opsPullResponseCodec =
      RpcCodec<OpsPullResponse>(OpsPullResponse.fromJson);
  static final opsSubscribeRequestCodec =
      RpcCodec<OpsSubscribeRequest>(OpsSubscribeRequest.fromJson);
  static final opsNotificationCodec =
      RpcCodec<OpsNotification>(OpsNotification.fromJson);
  static final invitesCreateRequestCodec =
      RpcCodec<InvitesCreateRequest>(InvitesCreateRequest.fromJson);
  static final invitesMutationResponseCodec =
      RpcCodec<InvitesMutationResponse>(InvitesMutationResponse.fromJson);
  static final invitesRespondRequestCodec =
      RpcCodec<InvitesRespondRequest>(InvitesRespondRequest.fromJson);
  static final invitesFinalizeRequestCodec =
      RpcCodec<InvitesFinalizeRequest>(InvitesFinalizeRequest.fromJson);
  static final invitesFetchRequestCodec =
      RpcCodec<InvitesFetchRequest>(InvitesFetchRequest.fromJson);
  static final invitesFetchResponseCodec =
      RpcCodec<InvitesFetchResponse>(InvitesFetchResponse.fromJson);
}
