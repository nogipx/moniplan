import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:rpc_dart/rpc_dart.dart';

import 'models.dart';
import 'monishare_contract.dart';

/// Реализация серверного контракта MoniShare.
class MoniShareResponder extends RpcResponderContract {
  MoniShareResponder({
    Duration? defaultInviteTtl,
    DateTime Function()? clock,
    String Function()? idGenerator,
  })  : _defaultInviteTtl = defaultInviteTtl ?? const Duration(days: 7),
        _clock = clock ?? DateTime.now,
        _idGenerator = idGenerator ?? _generateId,
        super(
          MoniShareContract.serviceName,
          dataTransferMode: RpcDataTransferMode.codec,
        );

  final Duration _defaultInviteTtl;
  final DateTime Function() _clock;
  final String Function() _idGenerator;

  final Map<String, Space> _spaces = {};
  final Map<String, List<OperationRecord>> _opsBySpace = {};
  final Map<String, int> _lastOpIndexBySpace = {};
  final Map<String, Invite> _invites = {};
  final Map<String, StreamController<OpsNotification>> _spaceStreams = {};

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
    for (final controller in _spaceStreams.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _spaceStreams.clear();
    super.dispose();
  }

  Future<SpacesRegisterResponse> _handleSpacesRegister(
    SpacesRegisterRequest request, {
    RpcContext? context,
  }) async {
    var candidate = request.plannerSpaceIdHint ?? _idGenerator();
    while (_spaces.containsKey(candidate)) {
      candidate = _idGenerator();
    }

    final now = _clock();
    final space = Space(plannerSpaceId: candidate, createdAt: now);
    _spaces[candidate] = space;
    _opsBySpace[candidate] = <OperationRecord>[];
    _lastOpIndexBySpace[candidate] = 0;

    return SpacesRegisterResponse(space: space);
  }

  Future<SpacesArchiveResponse> _handleSpacesArchive(
    SpacesArchiveRequest request, {
    RpcContext? context,
  }) async {
    final space = _requireSpace(request.plannerSpaceId);

    if (space.archivedAt != null) {
      return SpacesArchiveResponse(space: space);
    }

    final archived = space.copyWith(archivedAt: _clock());
    _spaces[space.plannerSpaceId] = archived;
    return SpacesArchiveResponse(space: archived);
  }

  Future<OpsAppendResponse> _handleOpsAppend(
    OpsAppendRequest request, {
    RpcContext? context,
  }) async {
    final space = _requireSpace(request.plannerSpaceId);

    if (space.archivedAt != null) {
      throw MoniShareException(
        'space_archived',
        'Space ${space.plannerSpaceId} is archived',
      );
    }

    final payloads = request.operations;
    if (payloads.isEmpty) {
      return OpsAppendResponse(
        plannerSpaceId: request.plannerSpaceId,
        lastOpIdx: _lastOpIndexBySpace[space.plannerSpaceId] ?? 0,
        appendedCount: 0,
      );
    }

    final operations = _opsBySpace[space.plannerSpaceId] ??= [];
    var lastIdx = _lastOpIndexBySpace[space.plannerSpaceId] ?? 0;

    for (final payload in payloads) {
      lastIdx += 1;
      final record = OperationRecord(
        plannerSpaceId: space.plannerSpaceId,
        opIdx: lastIdx,
        tsServer: _clock(),
        actorPseudoId: payload.actorPseudoId,
        cipherLen: payload.cipherLen,
        cipherHash: payload.cipherHash,
        ciphertextB64: payload.ciphertextB64,
      );
      operations.add(record);
    }

    _lastOpIndexBySpace[space.plannerSpaceId] = lastIdx;
    _notifySubscribers(
      space.plannerSpaceId,
      lastIdx: lastIdx,
      batchSize: payloads.length,
    );

    return OpsAppendResponse(
      plannerSpaceId: space.plannerSpaceId,
      lastOpIdx: lastIdx,
      appendedCount: payloads.length,
    );
  }

  Future<OpsPullResponse> _handleOpsPull(
    OpsPullRequest request, {
    RpcContext? context,
  }) async {
    _requireSpace(request.plannerSpaceId);

    final operations = _opsBySpace[request.plannerSpaceId] ?? const [];
    final filtered = operations
        .where((op) => op.opIdx > request.sinceOpIdx)
        .sortedBy<num>((op) => op.opIdx)
        .toList();

    final limited = request.limit == null
        ? filtered
        : filtered.take(request.limit!).toList();

    return OpsPullResponse(operations: limited);
  }

  Stream<OpsNotification> _handleOpsSubscribe(
    OpsSubscribeRequest request, {
    RpcContext? context,
  }) {
    _requireSpace(request.plannerSpaceId);

    final controller = _spaceStreams.putIfAbsent(
      request.plannerSpaceId,
      () => StreamController<OpsNotification>.broadcast(),
    );

    return controller.stream;
  }

  Future<InvitesMutationResponse> _handleInvitesCreate(
    InvitesCreateRequest request, {
    RpcContext? context,
  }) async {
    _requireSpace(request.plannerSpaceId);

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

    _invites[inviteId] = invite;

    return InvitesMutationResponse(invite: invite);
  }

  Future<InvitesMutationResponse> _handleInvitesRespond(
    InvitesRespondRequest request, {
    RpcContext? context,
  }) async {
    final invite = _requireInvite(request.inviteId);
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

    _invites[invite.inviteId] = updated;
    return InvitesMutationResponse(invite: updated);
  }

  Future<InvitesMutationResponse> _handleInvitesFinalize(
    InvitesFinalizeRequest request, {
    RpcContext? context,
  }) async {
    final invite = _requireInvite(request.inviteId);
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

    _invites[invite.inviteId] = updated;
    return InvitesMutationResponse(invite: updated);
  }

  Future<InvitesFetchResponse> _handleInvitesFetch(
    InvitesFetchRequest request, {
    RpcContext? context,
  }) async {
    final invite = _invites[request.inviteId];
    if (invite == null) {
      return const InvitesFetchResponse(invite: null);
    }

    if (_isExpired(invite)) {
      final expired = invite.copyWith(state: InviteState.expired);
      _invites[invite.inviteId] = expired;
      return InvitesFetchResponse(invite: expired);
    }

    return InvitesFetchResponse(invite: invite);
  }

  Space _requireSpace(String plannerSpaceId) {
    final space = _spaces[plannerSpaceId];
    if (space == null) {
      throw MoniShareException(
        'space_not_found',
        'Space $plannerSpaceId not found',
      );
    }
    return space;
  }

  Invite _requireInvite(String inviteId) {
    final invite = _invites[inviteId];
    if (invite == null) {
      throw MoniShareException(
          'invite_not_found', 'Invite $inviteId not found');
    }

    if (_isExpired(invite)) {
      final expired = invite.copyWith(state: InviteState.expired);
      _invites[invite.inviteId] = expired;
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

  void _notifySubscribers(
    String plannerSpaceId, {
    required int lastIdx,
    required int batchSize,
  }) {
    final controller = _spaceStreams[plannerSpaceId];
    if (controller == null || controller.isClosed) {
      return;
    }

    final notification = OpsNotification(
      plannerSpaceId: plannerSpaceId,
      lastOpIdx: lastIdx,
      batchSize: batchSize,
    );

    // Не логируем содержимое операций.
    controller.add(notification);
  }
}
