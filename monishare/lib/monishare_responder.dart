import 'dart:async';
import 'dart:math';

import 'package:rpc_dart/rpc_dart.dart';

import 'models.dart';
import 'monishare_contract.dart';
import 'monishare_responder_repository.dart';

/// Реализация серверного контракта MoniShare.
class MoniShareResponder extends RpcResponderContract {
  MoniShareResponder({
    MoniShareResponderRepository? repository,
    Duration? defaultInviteTtl,
    DateTime Function()? clock,
    String Function()? idGenerator,
  })  : _repository = repository ?? InMemoryMoniShareResponderRepository(),
        _defaultInviteTtl = defaultInviteTtl ?? const Duration(days: 7),
        _clock = clock ?? DateTime.now,
        _idGenerator = idGenerator ?? _generateId,
        super(
          MoniShareContract.serviceName,
          dataTransferMode: RpcDataTransferMode.codec,
        );

  final MoniShareResponderRepository _repository;
  final Duration _defaultInviteTtl;
  final DateTime Function() _clock;
  final String Function() _idGenerator;

  static final Random _random = Random.secure();

  static String _generateId() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(alphabet[_random.nextInt(alphabet.length)]);
    }
    return buffer.toString();
  }

  @override
  void setup() {
    addUnaryMethod<SpacesRegisterRequest, SpacesRegisterResponse>(
      methodName: MoniShareContract.methodSpacesRegister,
      handler: _handleSpacesRegister,
      requestCodec: MoniShareContract.spacesRegisterRequestCodec,
      responseCodec: MoniShareContract.spacesRegisterResponseCodec,
    );

    addUnaryMethod<SpacesArchiveRequest, SpacesArchiveResponse>(
      methodName: MoniShareContract.methodSpacesArchive,
      handler: _handleSpacesArchive,
      requestCodec: MoniShareContract.spacesArchiveRequestCodec,
      responseCodec: MoniShareContract.spacesArchiveResponseCodec,
    );

    addUnaryMethod<OpsAppendRequest, OpsAppendResponse>(
      methodName: MoniShareContract.methodOpsAppend,
      handler: _handleOpsAppend,
      requestCodec: MoniShareContract.opsAppendRequestCodec,
      responseCodec: MoniShareContract.opsAppendResponseCodec,
    );

    addUnaryMethod<OpsPullRequest, OpsPullResponse>(
      methodName: MoniShareContract.methodOpsPull,
      handler: _handleOpsPull,
      requestCodec: MoniShareContract.opsPullRequestCodec,
      responseCodec: MoniShareContract.opsPullResponseCodec,
    );

    addServerStreamMethod<OpsSubscribeRequest, OpsNotification>(
      methodName: MoniShareContract.methodOpsSubscribe,
      handler: _handleOpsSubscribe,
      requestCodec: MoniShareContract.opsSubscribeRequestCodec,
      responseCodec: MoniShareContract.opsNotificationCodec,
    );

    addUnaryMethod<InvitesCreateRequest, InvitesMutationResponse>(
      methodName: MoniShareContract.methodInvitesCreate,
      handler: _handleInvitesCreate,
      requestCodec: MoniShareContract.invitesCreateRequestCodec,
      responseCodec: MoniShareContract.invitesMutationResponseCodec,
    );

    addUnaryMethod<InvitesRespondRequest, InvitesMutationResponse>(
      methodName: MoniShareContract.methodInvitesRespond,
      handler: _handleInvitesRespond,
      requestCodec: MoniShareContract.invitesRespondRequestCodec,
      responseCodec: MoniShareContract.invitesMutationResponseCodec,
    );

    addUnaryMethod<InvitesFinalizeRequest, InvitesMutationResponse>(
      methodName: MoniShareContract.methodInvitesFinalize,
      handler: _handleInvitesFinalize,
      requestCodec: MoniShareContract.invitesFinalizeRequestCodec,
      responseCodec: MoniShareContract.invitesMutationResponseCodec,
    );

    addUnaryMethod<InvitesFetchRequest, InvitesFetchResponse>(
      methodName: MoniShareContract.methodInvitesFetch,
      handler: _handleInvitesFetch,
      requestCodec: MoniShareContract.invitesFetchRequestCodec,
      responseCodec: MoniShareContract.invitesFetchResponseCodec,
    );
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<SpacesRegisterResponse> _handleSpacesRegister(
    SpacesRegisterRequest request, {
    RpcContext? context,
  }) async {
    var candidate = request.plannerSpaceIdHint ?? _idGenerator();
    while (await _repository.spaceExists(candidate)) {
      candidate = _idGenerator();
    }

    final now = _clock();
    final space = Space(plannerSpaceId: candidate, createdAt: now);
    await _repository.createSpace(space);

    return SpacesRegisterResponse(space: space);
  }

  Future<SpacesArchiveResponse> _handleSpacesArchive(
    SpacesArchiveRequest request, {
    RpcContext? context,
  }) async {
    final space = await _requireSpace(request.plannerSpaceId);

    if (space.archivedAt != null) {
      return SpacesArchiveResponse(space: space);
    }

    final archived = space.copyWith(archivedAt: _clock());
    await _repository.saveSpace(archived);
    return SpacesArchiveResponse(space: archived);
  }

  Future<OpsAppendResponse> _handleOpsAppend(
    OpsAppendRequest request, {
    RpcContext? context,
  }) async {
    final space = await _requireSpace(request.plannerSpaceId);

    if (space.archivedAt != null) {
      throw MoniShareException(
        'space_archived',
        'Space ${space.plannerSpaceId} is archived',
      );
    }

    final payloads = request.operations;
    final appendResult = await _repository.appendOperations(
      space.plannerSpaceId,
      payloads,
      _clock,
    );

    return OpsAppendResponse(
      plannerSpaceId: space.plannerSpaceId,
      lastOpIdx: appendResult.lastOpIdx,
      appendedCount: appendResult.appendedCount,
    );
  }

  Future<OpsPullResponse> _handleOpsPull(
    OpsPullRequest request, {
    RpcContext? context,
  }) async {
    await _requireSpace(request.plannerSpaceId);

    final operations = await _repository.fetchOperations(
      request.plannerSpaceId,
      request.sinceOpIdx,
      limit: request.limit,
    );

    return OpsPullResponse(operations: operations);
  }

  Stream<OpsNotification> _handleOpsSubscribe(
    OpsSubscribeRequest request, {
    RpcContext? context,
  }) async* {
    await _requireSpace(request.plannerSpaceId);

    yield* _repository.subscribeToSpace(request.plannerSpaceId);
  }

  Future<InvitesMutationResponse> _handleInvitesCreate(
    InvitesCreateRequest request, {
    RpcContext? context,
  }) async {
    await _requireSpace(request.plannerSpaceId);

    final inviteId = _idGenerator();
    final createdAt = _clock();
    final expiresAt = request.expiresAt ??
        (request.ttlSeconds != null
            ? createdAt.add(Duration(seconds: request.ttlSeconds!))
            : createdAt.add(_defaultInviteTtl));

    final invite = Invite(
      inviteId: inviteId,
      createdAt: createdAt,
      state: InviteState.created,
      expiresAt: expiresAt,
      ownerHandshakeB64: request.ownerHandshakeB64,
    );

    await _repository.saveInvite(invite);

    return InvitesMutationResponse(invite: invite);
  }

  Future<InvitesMutationResponse> _handleInvitesRespond(
    InvitesRespondRequest request, {
    RpcContext? context,
  }) async {
    final invite = await _requireInvite(request.inviteId);
    _ensureInviteActive(invite);

    if (invite.state != InviteState.created) {
      throw MoniShareException(
        'invalid_state',
        'Invite ${invite.inviteId} cannot accept response in state ${invite.state.name}',
      );
    }

    final updated = invite.copyWith(
      state: InviteState.responded,
      joinerHandshakeB64: request.joinerHandshakeB64,
    );

    await _repository.saveInvite(updated);
    return InvitesMutationResponse(invite: updated);
  }

  Future<InvitesMutationResponse> _handleInvitesFinalize(
    InvitesFinalizeRequest request, {
    RpcContext? context,
  }) async {
    final invite = await _requireInvite(request.inviteId);
    _ensureInviteActive(invite);

    if (invite.state != InviteState.responded) {
      throw MoniShareException(
        'invalid_state',
        'Invite ${invite.inviteId} cannot be finalized in state ${invite.state.name}',
      );
    }

    final updated = invite.copyWith(
      state: InviteState.finalized,
      finalHandshakeB64: request.finalHandshakeB64,
      encryptedEnvelopeB64: request.encryptedEnvelopeB64,
    );

    await _repository.saveInvite(updated);
    return InvitesMutationResponse(invite: updated);
  }

  Future<InvitesFetchResponse> _handleInvitesFetch(
    InvitesFetchRequest request, {
    RpcContext? context,
  }) async {
    final invite = await _repository.findInvite(request.inviteId);
    if (invite == null) {
      return const InvitesFetchResponse(invite: null);
    }

    if (_isExpired(invite)) {
      final expired = invite.copyWith(state: InviteState.expired);
      await _repository.saveInvite(expired);
      return InvitesFetchResponse(invite: expired);
    }

    return InvitesFetchResponse(invite: invite);
  }

  Future<Space> _requireSpace(String plannerSpaceId) async {
    final space = await _repository.findSpace(plannerSpaceId);
    if (space == null) {
      throw MoniShareException(
        'space_not_found',
        'Space $plannerSpaceId not found',
      );
    }
    return space;
  }

  Future<Invite> _requireInvite(String inviteId) async {
    final invite = await _repository.findInvite(inviteId);
    if (invite == null) {
      throw MoniShareException(
          'invite_not_found', 'Invite $inviteId not found');
    }

    if (_isExpired(invite)) {
      final expired = invite.copyWith(state: InviteState.expired);
      await _repository.saveInvite(expired);
      throw MoniShareException('invite_expired', 'Invite $inviteId expired');
    }

    return invite;
  }

  void _ensureInviteActive(Invite invite) {
    if (invite.state == InviteState.expired) {
      throw MoniShareException(
          'invite_expired', 'Invite ${invite.inviteId} expired');
    }
  }

  bool _isExpired(Invite invite) {
    if (invite.expiresAt == null) {
      return false;
    }
    return _clock().isAfter(invite.expiresAt!);
  }
}
