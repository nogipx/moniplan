import 'package:rpc_dart/rpc_dart.dart';

import 'models.dart';
import 'monishare_contract.dart';

/// Клиент MoniShare поверх RpcCallerContract.
class MoniShareClient extends RpcCallerContract {
  MoniShareClient(RpcCallerEndpoint endpoint)
      : super(
          MoniShareContract.serviceName,
          endpoint,
          dataTransferMode: RpcDataTransferMode.codec,
        );

  Future<SpacesRegisterResponse> spacesRegister({
    String? plannerSpaceIdHint,
    RpcContext? context,
  }) {
    return callUnary<SpacesRegisterRequest, SpacesRegisterResponse>(
      methodName: MoniShareContract.methodSpacesRegister,
      request: SpacesRegisterRequest(plannerSpaceIdHint: plannerSpaceIdHint),
      requestCodec: MoniShareContract.spacesRegisterRequestCodec,
      responseCodec: MoniShareContract.spacesRegisterResponseCodec,
      context: context,
    );
  }

  Future<SpacesArchiveResponse> spacesArchive({
    required String plannerSpaceId,
    RpcContext? context,
  }) {
    return callUnary<SpacesArchiveRequest, SpacesArchiveResponse>(
      methodName: MoniShareContract.methodSpacesArchive,
      request: SpacesArchiveRequest(plannerSpaceId: plannerSpaceId),
      requestCodec: MoniShareContract.spacesArchiveRequestCodec,
      responseCodec: MoniShareContract.spacesArchiveResponseCodec,
      context: context,
    );
  }

  Future<OpsAppendResponse> opsAppend({
    required String plannerSpaceId,
    required List<OperationPayload> operations,
    RpcContext? context,
  }) {
    return callUnary<OpsAppendRequest, OpsAppendResponse>(
      methodName: MoniShareContract.methodOpsAppend,
      request: OpsAppendRequest(
        plannerSpaceId: plannerSpaceId,
        operations: operations,
      ),
      requestCodec: MoniShareContract.opsAppendRequestCodec,
      responseCodec: MoniShareContract.opsAppendResponseCodec,
      context: context,
    );
  }

  Future<OpsPullResponse> opsPull({
    required String plannerSpaceId,
    required int sinceOpIdx,
    int? limit,
    RpcContext? context,
  }) {
    return callUnary<OpsPullRequest, OpsPullResponse>(
      methodName: MoniShareContract.methodOpsPull,
      request: OpsPullRequest(
        plannerSpaceId: plannerSpaceId,
        sinceOpIdx: sinceOpIdx,
        limit: limit,
      ),
      requestCodec: MoniShareContract.opsPullRequestCodec,
      responseCodec: MoniShareContract.opsPullResponseCodec,
      context: context,
    );
  }

  Stream<OpsNotification> opsSubscribe({
    required String plannerSpaceId,
    RpcContext? context,
  }) {
    return callServerStream<OpsSubscribeRequest, OpsNotification>(
      methodName: MoniShareContract.methodOpsSubscribe,
      request: OpsSubscribeRequest(plannerSpaceId: plannerSpaceId),
      requestCodec: MoniShareContract.opsSubscribeRequestCodec,
      responseCodec: MoniShareContract.opsNotificationCodec,
      context: context,
    );
  }

  Future<InvitesMutationResponse> invitesCreate({
    required String plannerSpaceId,
    required String ownerHandshakeB64,
    DateTime? expiresAt,
    int? ttlSeconds,
    RpcContext? context,
  }) {
    return callUnary<InvitesCreateRequest, InvitesMutationResponse>(
      methodName: MoniShareContract.methodInvitesCreate,
      request: InvitesCreateRequest(
        plannerSpaceId: plannerSpaceId,
        ownerHandshakeB64: ownerHandshakeB64,
        expiresAt: expiresAt,
        ttlSeconds: ttlSeconds,
      ),
      requestCodec: MoniShareContract.invitesCreateRequestCodec,
      responseCodec: MoniShareContract.invitesMutationResponseCodec,
      context: context,
    );
  }

  Future<InvitesMutationResponse> invitesRespond({
    required String inviteId,
    required String joinerHandshakeB64,
    RpcContext? context,
  }) {
    return callUnary<InvitesRespondRequest, InvitesMutationResponse>(
      methodName: MoniShareContract.methodInvitesRespond,
      request: InvitesRespondRequest(
        inviteId: inviteId,
        joinerHandshakeB64: joinerHandshakeB64,
      ),
      requestCodec: MoniShareContract.invitesRespondRequestCodec,
      responseCodec: MoniShareContract.invitesMutationResponseCodec,
      context: context,
    );
  }

  Future<InvitesMutationResponse> invitesFinalize({
    required String inviteId,
    required String finalHandshakeB64,
    required String encryptedEnvelopeB64,
    RpcContext? context,
  }) {
    return callUnary<InvitesFinalizeRequest, InvitesMutationResponse>(
      methodName: MoniShareContract.methodInvitesFinalize,
      request: InvitesFinalizeRequest(
        inviteId: inviteId,
        finalHandshakeB64: finalHandshakeB64,
        encryptedEnvelopeB64: encryptedEnvelopeB64,
      ),
      requestCodec: MoniShareContract.invitesFinalizeRequestCodec,
      responseCodec: MoniShareContract.invitesMutationResponseCodec,
      context: context,
    );
  }

  Future<InvitesFetchResponse> invitesFetch({
    required String inviteId,
    RpcContext? context,
  }) {
    return callUnary<InvitesFetchRequest, InvitesFetchResponse>(
      methodName: MoniShareContract.methodInvitesFetch,
      request: InvitesFetchRequest(inviteId: inviteId),
      requestCodec: MoniShareContract.invitesFetchRequestCodec,
      responseCodec: MoniShareContract.invitesFetchResponseCodec,
      context: context,
    );
  }
}
