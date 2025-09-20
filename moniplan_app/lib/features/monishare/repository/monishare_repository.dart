import 'dart:async';

import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monishare/models/monishare_invite_local.dart';
import 'package:moniplan_app/features/monishare/models/monishare_space_info.dart';
import 'package:moniplan_app/features/monishare/services/monishare_local_store.dart';
import 'package:moniplan_app/features/monishare/services/monishare_service.dart';
import 'package:moniplan_app/features/payment/repo/i_payment_planner_repo.dart';
import 'package:monishare/models.dart';
import 'package:monishare/monishare_client.dart';
import 'package:monishare/monishare_contract.dart';

/// Репозиторий для работы с данными MoniShare.
class MonishareRepository {
  MonishareRepository({
    required IPlannerRepo plannerRepo,
    required MonishareService monishareService,
    required MonishareLocalStore localStore,
  }) : _plannerRepo = plannerRepo,
       _monishareService = monishareService,
       _localStore = localStore;

  final IPlannerRepo _plannerRepo;
  final MonishareService _monishareService;
  final MonishareLocalStore _localStore;

  bool get isConnected => _monishareService.isConnected;

  Stream<bool> get statusStream => _monishareService.statusStream;

  MoniShareClient get _client => _monishareService.client;

  Future<void> ensureServiceStarted() => _monishareService.ensureStarted();

  Future<List<Planner>> loadPlanners() {
    return _plannerRepo.getPlanners(withPayments: false, withActualInfo: false);
  }

  Future<Planner?> loadPlanner(String plannerId) {
    return _plannerRepo.getPlannerById(plannerId, withActualInfo: true);
  }

  Future<MonishareSpaceInfo?> loadSpace(String plannerId) {
    return _localStore.loadSpace(plannerId);
  }

  Future<List<MonishareSpaceInfo>> loadSpaces() {
    return _localStore.loadSpaces();
  }

  Future<void> saveSpace(MonishareSpaceInfo info) {
    return _localStore.saveSpace(info);
  }

  Future<void> deleteSpace(String plannerId) {
    return _localStore.deleteSpace(plannerId);
  }

  Future<List<MonishareInviteLocal>> loadInvites(String plannerId) {
    return _localStore.loadInvites(plannerId);
  }

  Future<void> upsertInvite(String plannerId, MonishareInviteLocal invite) {
    return _localStore.upsertInvite(plannerId, invite);
  }

  Future<void> removeInvite(String plannerId, String inviteId) {
    return _localStore.removeInvite(plannerId, inviteId);
  }

  Future<void> clearInvites(String plannerId) {
    return _localStore.clearInvites(plannerId);
  }

  Future<SpacesRegisterResponse> registerSpace({String? plannerSpaceIdHint}) {
    return _client.spacesRegister(plannerSpaceIdHint: plannerSpaceIdHint);
  }

  Future<OpsPullResponse> pullOperations({
    required String plannerSpaceId,
    required int sinceOpIdx,
    int? limit,
  }) {
    return _client.opsPull(plannerSpaceId: plannerSpaceId, sinceOpIdx: sinceOpIdx, limit: limit);
  }

  Future<OpsAppendResponse> appendOperations({
    required String plannerSpaceId,
    required List<OperationPayload> operations,
  }) {
    return _client.opsAppend(plannerSpaceId: plannerSpaceId, operations: operations);
  }

  Stream<OpsNotification> subscribeToOperations(String plannerSpaceId) {
    return _client.opsSubscribe(plannerSpaceId: plannerSpaceId);
  }

  Future<InvitesMutationResponse> createInvite({
    required String plannerSpaceId,
    required String ownerHandshakeB64,
    DateTime? expiresAt,
    int? ttlSeconds,
  }) {
    return _client.invitesCreate(
      plannerSpaceId: plannerSpaceId,
      ownerHandshakeB64: ownerHandshakeB64,
      expiresAt: expiresAt,
      ttlSeconds: ttlSeconds,
    );
  }

  Future<InvitesMutationResponse> respondToInvite({
    required String inviteId,
    required String joinerHandshakeB64,
  }) {
    return _client.invitesRespond(inviteId: inviteId, joinerHandshakeB64: joinerHandshakeB64);
  }

  Future<InvitesMutationResponse> finalizeInvite({
    required String inviteId,
    required String finalHandshakeB64,
    required String encryptedEnvelopeB64,
  }) {
    return _client.invitesFinalize(
      inviteId: inviteId,
      finalHandshakeB64: finalHandshakeB64,
      encryptedEnvelopeB64: encryptedEnvelopeB64,
    );
  }

  Future<InvitesFetchResponse> fetchInvite(String inviteId) {
    return _client.invitesFetch(inviteId: inviteId);
  }
}
