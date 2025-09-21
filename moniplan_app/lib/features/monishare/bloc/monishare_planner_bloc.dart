import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monishare/models/monishare_invite_local.dart';
import 'package:moniplan_app/features/monishare/models/monishare_space_info.dart';
import 'package:moniplan_app/features/monishare/repository/monishare_repository.dart';
import 'package:monishare/models.dart';

part 'monishare_planner_event.dart';
part 'monishare_planner_state.dart';

class MonisharePlannerBloc extends Bloc<MonisharePlannerEvent, MonisharePlannerState> {
  MonisharePlannerBloc({
    required this.plannerId,
    required MonishareRepository repository,
  }) : _repository = repository,
       _random = _createRandom(),
       super(const MonisharePlannerState()) {
    on<MonisharePlannerStarted>(_onStarted);
    on<MonisharePlannerEnsureSpaceRequested>(_onEnsureSpaceRequested);
    on<MonisharePlannerRefreshOperationsRequested>(_onRefreshOperationsRequested);
    on<MonisharePlannerAppendSnapshotRequested>(_onAppendSnapshotRequested);
    on<MonisharePlannerCreateInviteRequested>(_onCreateInviteRequested);
    on<MonisharePlannerRefreshInvitesRequested>(_onRefreshInvitesRequested);
    on<MonisharePlannerFinalizeInviteRequested>(_onFinalizeInviteRequested);
    on<MonisharePlannerSubscriptionToggled>(_onSubscriptionToggled);
    on<_MonisharePlannerNotificationReceived>(_onNotificationReceived);
    on<MonisharePlannerRemoveSpaceRequested>(_onRemoveSpaceRequested);
    on<MonisharePlannerJoinerInviteFetchRequested>(_onJoinerInviteFetchRequested);
    on<MonisharePlannerJoinerRespondRequested>(_onJoinerRespondRequested);
    on<MonisharePlannerJoinerRefreshRequested>(_onJoinerRefreshRequested);
    on<MonisharePlannerApplyEnvelopeRequested>(_onApplyEnvelopeRequested);
    on<MonisharePlannerMessageCleared>(_onMessageCleared);
  }

  final String plannerId;
  final MonishareRepository _repository;
  final Random _random;
  StreamSubscription<OpsNotification>? _subscription;

  static Random _createRandom() {
    try {
      return Random.secure();
    } on UnsupportedError {
      return Random();
    } on Exception {
      return Random();
    }
  }

  String _randomB64([int length = 32]) {
    final bytes = List<int>.generate(length, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }

  Future<void> _onStarted(
    MonisharePlannerStarted event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      final planner = await _repository.loadPlanner(plannerId);
      final space = await _repository.loadSpace(plannerId);
      final invites = await _repository.loadInvites(plannerId);

      emit(
        state.copyWith(
          isLoading: false,
          planner: planner,
          space: space,
          invites: invites,
        ),
      );

      if (space != null) {
        add(MonisharePlannerRefreshOperationsRequested(space: space));
        add(const MonisharePlannerRefreshInvitesRequested());
      }
    } on Object catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Не удалось загрузить данные: $error',
        ),
      );
    }
  }

  Future<void> _onEnsureSpaceRequested(
    MonisharePlannerEnsureSpaceRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    if (state.space != null) {
      return;
    }

    emit(state.copyWith(ownerBusy: true, clearMessages: true));

    try {
      final response = await _repository.registerSpace();
      final actorId = 'actor-${_randomB64(6)}';
      final spaceKey = _randomB64(32);
      final info = MonishareSpaceInfo(
        plannerId: plannerId,
        plannerSpaceId: response.space.plannerSpaceId,
        actorPseudoId: actorId,
        spaceKeyB64: spaceKey,
      );
      await _repository.saveSpace(info);
      emit(
        state.copyWith(
          ownerBusy: false,
          space: info,
          message: 'Пространство создано',
        ),
      );
      add(MonisharePlannerRefreshOperationsRequested(space: info));
    } on Object catch (error) {
      emit(
        state.copyWith(
          ownerBusy: false,
          errorMessage: 'Не удалось создать пространство: $error',
        ),
      );
    }
  }

  Future<void> _onRefreshOperationsRequested(
    MonisharePlannerRefreshOperationsRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    final space = event.space ?? state.space;
    if (space == null) {
      return;
    }

    try {
      final response = await _repository.pullOperations(
        plannerSpaceId: space.plannerSpaceId,
        sinceOpIdx: 0,
      );
      final lastIdx =
          response.operations.isEmpty ? space.lastSyncedOpIdx : response.operations.last.opIdx;
      final updatedSpace = space.copyWith(lastSyncedOpIdx: lastIdx);
      await _repository.saveSpace(updatedSpace);
      emit(
        state.copyWith(
          space: updatedSpace,
          operations: response.operations,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(errorMessage: 'Не удалось получить операции: $error'),
      );
    }
  }

  Future<void> _onAppendSnapshotRequested(
    MonisharePlannerAppendSnapshotRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    final planner = state.planner;
    final space = state.space;
    if (planner == null || space == null) {
      return;
    }

    emit(state.copyWith(ownerBusy: true, clearMessages: true));

    try {
      final json = jsonEncode(planner.toJson());
      final ciphertext = base64Encode(utf8.encode(json));
      final hash = sha256.convert(utf8.encode(ciphertext)).toString();
      await _repository.appendOperations(
        plannerSpaceId: space.plannerSpaceId,
        operations: [
          OperationPayload(
            actorPseudoId: space.actorPseudoId,
            cipherLen: ciphertext.length,
            cipherHash: hash,
            ciphertextB64: ciphertext,
          ),
        ],
      );
      emit(state.copyWith(message: 'Снимок планнера опубликован'));
      add(MonisharePlannerRefreshOperationsRequested(space: space));
    } on Object catch (error) {
      emit(
        state.copyWith(
          ownerBusy: false,
          errorMessage: 'Не удалось отправить операции: $error',
        ),
      );
      return;
    }

    emit(state.copyWith(ownerBusy: false));
  }

  Future<void> _onCreateInviteRequested(
    MonisharePlannerCreateInviteRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    final space = state.space;
    if (space == null) {
      return;
    }

    emit(state.copyWith(ownerBusy: true, clearMessages: true));

    try {
      final ownerHandshake = _randomB64(24);
      final response = await _repository.createInvite(
        plannerSpaceId: space.plannerSpaceId,
        ownerHandshakeB64: ownerHandshake,
        ttlSeconds: 3600,
      );
      final invite = MonishareInviteLocal(
        inviteId: response.invite.inviteId,
        createdAt: response.invite.createdAt,
        state: response.invite.state,
        expiresAt: response.invite.expiresAt,
        ownerHandshakeB64: ownerHandshake,
        joinerHandshakeB64: response.invite.joinerHandshakeB64,
        finalHandshakeB64: response.invite.finalHandshakeB64,
        encryptedEnvelopeB64: response.invite.encryptedEnvelopeB64,
      );
      await _repository.upsertInvite(plannerId, invite);
      final updatedInvites = [invite, ...state.invites.where((i) => i.inviteId != invite.inviteId)];
      emit(
        state.copyWith(
          ownerBusy: false,
          invites: updatedInvites,
          message: 'Инвайт создан. Поделитесь идентификатором ${invite.inviteId}',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          ownerBusy: false,
          errorMessage: 'Не удалось создать инвайт: $error',
        ),
      );
    }
  }

  Future<void> _onRefreshInvitesRequested(
    MonisharePlannerRefreshInvitesRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    final space = state.space;
    if (space == null) {
      return;
    }

    try {
      final invites = await _repository.loadInvites(plannerId);
      final updated = <MonishareInviteLocal>[];
      for (final invite in invites) {
        final response = await _repository.fetchInvite(invite.inviteId);
        final remote = response.invite;
        if (remote != null) {
          final merged = invite.copyWith(
            state: remote.state,
            expiresAt: remote.expiresAt,
            ownerHandshakeB64: remote.ownerHandshakeB64 ?? invite.ownerHandshakeB64,
            joinerHandshakeB64: remote.joinerHandshakeB64 ?? invite.joinerHandshakeB64,
            finalHandshakeB64: remote.finalHandshakeB64 ?? invite.finalHandshakeB64,
            encryptedEnvelopeB64: remote.encryptedEnvelopeB64 ?? invite.encryptedEnvelopeB64,
          );
          updated.add(merged);
          await _repository.upsertInvite(plannerId, merged);
        } else {
          await _repository.removeInvite(plannerId, invite.inviteId);
        }
      }
      emit(state.copyWith(invites: updated));
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: 'Не удалось обновить инвайты: $error'));
    }
  }

  Future<void> _onFinalizeInviteRequested(
    MonisharePlannerFinalizeInviteRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    final space = state.space;
    if (space == null) {
      return;
    }

    emit(state.copyWith(ownerBusy: true, clearMessages: true));

    try {
      final finalHandshake = _randomB64(24);
      final joinerActor = 'actor-${_randomB64(6)}';
      final envelopeJson = jsonEncode({
        'plannerSpaceId': space.plannerSpaceId,
        'spaceKeyB64': space.spaceKeyB64,
        'actorPseudoId': joinerActor,
      });
      final envelopeB64 = base64Encode(utf8.encode(envelopeJson));
      final response = await _repository.finalizeInvite(
        inviteId: event.invite.inviteId,
        finalHandshakeB64: finalHandshake,
        encryptedEnvelopeB64: envelopeB64,
      );
      final updated = event.invite.copyWith(
        state: response.invite.state,
        finalHandshakeB64: finalHandshake,
        encryptedEnvelopeB64: envelopeB64,
      );
      await _repository.upsertInvite(plannerId, updated);
      emit(
        state.copyWith(
          ownerBusy: false,
          invites: [
            for (final existing in state.invites)
              if (existing.inviteId == updated.inviteId) updated else existing,
          ],
          message: 'Инвайт ${event.invite.inviteId} финализирован',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          ownerBusy: false,
          errorMessage: 'Не удалось финализировать инвайт: $error',
        ),
      );
    }
  }

  Future<void> _onSubscriptionToggled(
    MonisharePlannerSubscriptionToggled event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    if (event.subscribe) {
      final space = state.space;
      if (space == null || state.isSubscribed) {
        return;
      }
      await _subscription?.cancel();
      _subscription = _repository.subscribeToOperations(space.plannerSpaceId).listen((
        notification,
      ) {
        add(_MonisharePlannerNotificationReceived(notification: notification));
      });
      emit(state.copyWith(isSubscribed: true));
    } else {
      await _subscription?.cancel();
      _subscription = null;
      emit(state.copyWith(isSubscribed: false, lastNotification: null));
    }
  }

  void _onNotificationReceived(
    _MonisharePlannerNotificationReceived event,
    Emitter<MonisharePlannerState> emit,
  ) {
    emit(state.copyWith(lastNotification: event.notification));
    add(MonisharePlannerRefreshOperationsRequested());
  }

  Future<void> _onRemoveSpaceRequested(
    MonisharePlannerRemoveSpaceRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    final space = state.space;
    if (space == null) {
      return;
    }

    await _repository.deleteSpace(space.plannerId);
    await _subscription?.cancel();
    _subscription = null;
    emit(
      state.copyWith(
        space: null,
        operations: const [],
        invites: const [],
        isSubscribed: false,
        lastNotification: null,
        message: 'Пространство отключено локально',
      ),
    );
  }

  Future<void> _onJoinerInviteFetchRequested(
    MonisharePlannerJoinerInviteFetchRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    if (event.inviteId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Введите идентификатор инвайта'));
      return;
    }

    emit(state.copyWith(joinerBusy: true, clearMessages: true));

    try {
      final response = await _repository.fetchInvite(event.inviteId);
      emit(
        state.copyWith(
          joinerBusy: false,
          joinerInvite: response.invite,
        ),
      );
      if (response.invite == null) {
        emit(state.copyWith(message: 'Инвайт не найден или истёк'));
      }
    } on Object catch (error) {
      emit(
        state.copyWith(
          joinerBusy: false,
          errorMessage: 'Не удалось получить инвайт: $error',
        ),
      );
    }
  }

  Future<void> _onJoinerRespondRequested(
    MonisharePlannerJoinerRespondRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    final invite = state.joinerInvite;
    if (invite == null) {
      return;
    }

    emit(state.copyWith(joinerBusy: true, clearMessages: true));

    try {
      final handshake = _randomB64(24);
      final response = await _repository.respondToInvite(
        inviteId: invite.inviteId,
        joinerHandshakeB64: handshake,
      );
      emit(
        state.copyWith(
          joinerBusy: false,
          joinerInvite: response.invite,
          joinerResponseB64: handshake,
          message: 'Ответ отправлен. Ожидайте финализации владельцем.',
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          joinerBusy: false,
          errorMessage: 'Не удалось отправить ответ: $error',
        ),
      );
    }
  }

  Future<void> _onJoinerRefreshRequested(
    MonisharePlannerJoinerRefreshRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    final invite = state.joinerInvite;
    if (invite == null) {
      return;
    }

    emit(state.copyWith(joinerBusy: true, clearMessages: true));

    try {
      final response = await _repository.fetchInvite(invite.inviteId);
      emit(
        state.copyWith(
          joinerBusy: false,
          joinerInvite: response.invite,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          joinerBusy: false,
          errorMessage: 'Не удалось обновить статус: $error',
        ),
      );
    }
  }

  Future<void> _onApplyEnvelopeRequested(
    MonisharePlannerApplyEnvelopeRequested event,
    Emitter<MonisharePlannerState> emit,
  ) async {
    final invite = state.joinerInvite;
    if (invite == null || invite.encryptedEnvelopeB64 == null) {
      return;
    }

    try {
      final decoded = utf8.decode(base64Decode(invite.encryptedEnvelopeB64!));
      final data = jsonDecode(decoded);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Некорректный формат конверта');
      }
      final space = MonishareSpaceInfo(
        plannerId: plannerId,
        plannerSpaceId: data['plannerSpaceId'] as String,
        actorPseudoId: data['actorPseudoId'] as String,
        spaceKeyB64: data['spaceKeyB64'] as String,
        lastSyncedOpIdx: 0,
      );
      await _repository.saveSpace(space);
      emit(
        state.copyWith(
          space: space,
          message: 'Пространство MoniShare подключено',
        ),
      );
      add(MonisharePlannerRefreshOperationsRequested(space: space));
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: 'Не удалось применить конверт: $error'));
    }
  }

  void _onMessageCleared(
    MonisharePlannerMessageCleared event,
    Emitter<MonisharePlannerState> emit,
  ) {
    emit(state.copyWith(clearMessages: true));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
