import 'dart:async';

import 'package:collection/collection.dart';

import 'models.dart';

/// Результат добавления операций в пространство.
class AppendOperationsResult {
  AppendOperationsResult({
    required this.lastOpIdx,
    required this.appendedCount,
  });

  final int lastOpIdx;
  final int appendedCount;
}

/// Интерфейс репозитория для хранения данных MoniShareResponder.
abstract class MoniShareResponderRepository {
  Future<bool> spaceExists(String plannerSpaceId);

  Future<void> createSpace(Space space);

  Future<Space?> findSpace(String plannerSpaceId);

  Future<void> saveSpace(Space space);

  Future<AppendOperationsResult> appendOperations(
    String plannerSpaceId,
    Iterable<OperationPayload> payloads,
    DateTime Function() clock,
  );

  Future<List<OperationRecord>> fetchOperations(
    String plannerSpaceId,
    int sinceOpIdx, {
    int? limit,
  });

  Stream<OpsNotification> subscribeToSpace(String plannerSpaceId);

  Future<Invite?> findInvite(String inviteId);

  Future<void> saveInvite(Invite invite);

  void dispose();
}

/// Простая in-memory реализация репозитория для тестов и прототипа.
class InMemoryMoniShareResponderRepository
    implements MoniShareResponderRepository {
  final Map<String, Space> _spaces = {};
  final Map<String, List<OperationRecord>> _opsBySpace = {};
  final Map<String, int> _lastOpIndexBySpace = {};
  final Map<String, Invite> _invites = {};
  final Map<String, StreamController<OpsNotification>> _spaceStreams = {};

  @override
  Future<bool> spaceExists(String plannerSpaceId) async {
    return _spaces.containsKey(plannerSpaceId);
  }

  @override
  Future<void> createSpace(Space space) async {
    if (_spaces.containsKey(space.plannerSpaceId)) {
      throw StateError(
        'Space ${space.plannerSpaceId} already exists in repository',
      );
    }

    _spaces[space.plannerSpaceId] = space;
    _opsBySpace[space.plannerSpaceId] = <OperationRecord>[];
    _lastOpIndexBySpace[space.plannerSpaceId] = 0;
  }

  @override
  Future<Space?> findSpace(String plannerSpaceId) async {
    return _spaces[plannerSpaceId];
  }

  @override
  Future<void> saveSpace(Space space) async {
    if (!_spaces.containsKey(space.plannerSpaceId)) {
      throw StateError(
        'Space ${space.plannerSpaceId} must exist before saving',
      );
    }
    _spaces[space.plannerSpaceId] = space;
  }

  @override
  Future<AppendOperationsResult> appendOperations(
    String plannerSpaceId,
    Iterable<OperationPayload> payloads,
    DateTime Function() clock,
  ) async {
    final operations = _opsBySpace[plannerSpaceId];
    if (operations == null) {
      throw StateError('Space $plannerSpaceId is not initialised');
    }

    var lastIdx = _lastOpIndexBySpace[plannerSpaceId] ?? 0;
    if (payloads.isEmpty) {
      return AppendOperationsResult(lastOpIdx: lastIdx, appendedCount: 0);
    }

    var appended = 0;
    for (final payload in payloads) {
      lastIdx += 1;
      final record = OperationRecord(
        plannerSpaceId: plannerSpaceId,
        opIdx: lastIdx,
        tsServer: clock(),
        actorPseudoId: payload.actorPseudoId,
        cipherLen: payload.cipherLen,
        cipherHash: payload.cipherHash,
        ciphertextB64: payload.ciphertextB64,
      );
      operations.add(record);
      appended += 1;
    }

    _lastOpIndexBySpace[plannerSpaceId] = lastIdx;

    if (appended > 0) {
      final controller = _spaceStreams[plannerSpaceId];
      if (controller != null && !controller.isClosed) {
        controller.add(
          OpsNotification(
            plannerSpaceId: plannerSpaceId,
            lastOpIdx: lastIdx,
            batchSize: appended,
          ),
        );
      }
    }

    return AppendOperationsResult(
      lastOpIdx: lastIdx,
      appendedCount: appended,
    );
  }

  @override
  Future<List<OperationRecord>> fetchOperations(
    String plannerSpaceId,
    int sinceOpIdx, {
    int? limit,
  }) async {
    final operations = _opsBySpace[plannerSpaceId];
    if (operations == null) {
      throw StateError('Space $plannerSpaceId is not initialised');
    }

    final filtered = operations
        .where((op) => op.opIdx > sinceOpIdx)
        .sortedBy<num>((op) => op.opIdx)
        .toList();

    if (limit == null) {
      return filtered;
    }

    return filtered.take(limit).toList();
  }

  @override
  Stream<OpsNotification> subscribeToSpace(String plannerSpaceId) {
    final controller = _spaceStreams.putIfAbsent(
      plannerSpaceId,
      () => StreamController<OpsNotification>.broadcast(),
    );
    return controller.stream;
  }

  @override
  Future<Invite?> findInvite(String inviteId) async {
    return _invites[inviteId];
  }

  @override
  Future<void> saveInvite(Invite invite) async {
    _invites[invite.inviteId] = invite;
  }

  @override
  void dispose() {
    for (final controller in _spaceStreams.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _spaceStreams.clear();
  }
}
