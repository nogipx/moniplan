import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monishare/_index.dart';
import 'package:moniplan_app/features/payment/repo/i_payment_planner_repo.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:monishare/models.dart';

class MonisharePlannerScreen extends StatefulWidget {
  const MonisharePlannerScreen({required this.plannerId, super.key});

  final String plannerId;

  @override
  State<MonisharePlannerScreen> createState() =>
      _MonisharePlannerScreenState();
}

class _MonisharePlannerScreenState extends State<MonisharePlannerScreen> {
  final IPlannerRepo _plannerRepo = AppDi.instance.getPlannerRepo();
  final MonishareService _service = AppDi.instance.get<MonishareService>();
  final MonishareLocalStore _localStore = AppDi.instance.get<MonishareLocalStore>();

  late final Random _random = _createRandom();

  final _joinInviteController = TextEditingController();

  Planner? _planner;
  MonishareSpaceInfo? _space;
  List<OperationRecord> _operations = const [];
  List<MonishareInviteLocal> _invites = const [];
  Invite? _joinerInvite;
  String? _joinerResponseB64;
  OpsNotification? _lastNotification;

  bool _isLoading = true;
  bool _ownerBusy = false;
  bool _joinerBusy = false;
  bool _isSubscribed = false;

  StreamSubscription<OpsNotification>? _subscription;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _joinInviteController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _service.ensureStarted();
    final planner =
        await _plannerRepo.getPlannerById(widget.plannerId, withPayments: true, withActualInfo: true);
    final space = await _localStore.loadSpace(widget.plannerId);
    final invites = await _localStore.loadInvites(widget.plannerId);

    if (!mounted) {
      return;
    }

    setState(() {
      _planner = planner;
      _space = space;
      _invites = invites;
      _isLoading = false;
    });

    if (space != null) {
      await _refreshOperations(space);
      await _refreshInvites();
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Random _createRandom() {
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

  Future<void> _ensureSpace() async {
    if (_space != null) {
      return;
    }

    setState(() {
      _ownerBusy = true;
    });

    try {
      final response = await _service.client.spacesRegister();
      final actorId = 'actor-${_randomB64(6)}';
      final spaceKey = _randomB64(32);
      final info = MonishareSpaceInfo(
        plannerId: widget.plannerId,
        plannerSpaceId: response.space.plannerSpaceId,
        actorPseudoId: actorId,
        spaceKeyB64: spaceKey,
      );
      await _localStore.saveSpace(info);
      if (!mounted) {
        return;
      }
      setState(() {
        _space = info;
      });
      await _refreshOperations(info);
    } on Object catch (error) {
      _showMessage('Не удалось создать пространство: $error');
    } finally {
      if (mounted) {
        setState(() {
          _ownerBusy = false;
        });
      }
    }
  }

  Future<void> _refreshOperations([MonishareSpaceInfo? override]) async {
    final space = override ?? _space;
    if (space == null) {
      return;
    }

    try {
      final response = await _service.client.opsPull(
        plannerSpaceId: space.plannerSpaceId,
        sinceOpIdx: 0,
      );
      final lastIdx =
          response.operations.isEmpty ? space.lastSyncedOpIdx : response.operations.last.opIdx;
      final updated = space.copyWith(lastSyncedOpIdx: lastIdx);
      await _localStore.saveSpace(updated);
      if (!mounted) {
        return;
      }
      setState(() {
        _operations = response.operations;
        _space = updated;
      });
    } on Object catch (error) {
      _showMessage('Не удалось получить операции: $error');
    }
  }

  Future<void> _appendSnapshot() async {
    final planner = _planner;
    final space = _space;
    if (planner == null || space == null) {
      return;
    }

    setState(() {
      _ownerBusy = true;
    });

    try {
      final json = jsonEncode(planner.toJson());
      final ciphertext = base64Encode(utf8.encode(json));
      final hash = sha256.convert(utf8.encode(ciphertext)).toString();
      await _service.client.opsAppend(
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
      await _refreshOperations(space);
      _showMessage('Снимок планнера опубликован');
    } on Object catch (error) {
      _showMessage('Не удалось отправить операции: $error');
    } finally {
      if (mounted) {
        setState(() {
          _ownerBusy = false;
        });
      }
    }
  }

  Future<void> _createInvite() async {
    final space = _space;
    if (space == null) {
      return;
    }

    setState(() {
      _ownerBusy = true;
    });

    try {
      final ownerHandshake = _randomB64(24);
      final response = await _service.client.invitesCreate(
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
      await _localStore.upsertInvite(widget.plannerId, invite);
      if (!mounted) {
        return;
      }
      setState(() {
        _invites = [invite, ..._invites.where((i) => i.inviteId != invite.inviteId)];
      });
      _showMessage('Инвайт создан. Поделитесь идентификатором ${invite.inviteId}');
    } on Object catch (error) {
      _showMessage('Не удалось создать инвайт: $error');
    } finally {
      if (mounted) {
        setState(() {
          _ownerBusy = false;
        });
      }
    }
  }

  Future<void> _refreshInvites() async {
    final space = _space;
    if (space == null) {
      return;
    }

    try {
      final invites = await _localStore.loadInvites(widget.plannerId);
      final updated = <MonishareInviteLocal>[];
      for (final invite in invites) {
        final response = await _service.client.invitesFetch(inviteId: invite.inviteId);
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
          await _localStore.upsertInvite(widget.plannerId, merged);
        } else {
          await _localStore.removeInvite(widget.plannerId, invite.inviteId);
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _invites = updated;
      });
    } on Object catch (error) {
      _showMessage('Не удалось обновить инвайты: $error');
    }
  }

  Future<void> _finalizeInvite(MonishareInviteLocal invite) async {
    final space = _space;
    if (space == null) {
      return;
    }

    setState(() {
      _ownerBusy = true;
    });

    try {
      final finalHandshake = _randomB64(24);
      final joinerActor = 'actor-${_randomB64(6)}';
      final envelopeJson = jsonEncode({
        'plannerSpaceId': space.plannerSpaceId,
        'spaceKeyB64': space.spaceKeyB64,
        'actorPseudoId': joinerActor,
      });
      final envelopeB64 = base64Encode(utf8.encode(envelopeJson));
      final response = await _service.client.invitesFinalize(
        inviteId: invite.inviteId,
        finalHandshakeB64: finalHandshake,
        encryptedEnvelopeB64: envelopeB64,
      );
      final updated = invite.copyWith(
        state: response.invite.state,
        finalHandshakeB64: finalHandshake,
        encryptedEnvelopeB64: envelopeB64,
      );
      await _localStore.upsertInvite(widget.plannerId, updated);
      if (!mounted) {
        return;
      }
      setState(() {
        _invites = [
          for (final existing in _invites)
            if (existing.inviteId == updated.inviteId) updated else existing,
        ];
      });
      _showMessage('Инвайт ${invite.inviteId} финализирован');
    } on Object catch (error) {
      _showMessage('Не удалось финализировать инвайт: $error');
    } finally {
      if (mounted) {
        setState(() {
          _ownerBusy = false;
        });
      }
    }
  }

  void _subscribe() {
    final space = _space;
    if (space == null || _isSubscribed) {
      return;
    }
    _subscription?.cancel();
    _subscription = _service.client
        .opsSubscribe(plannerSpaceId: space.plannerSpaceId)
        .listen((notification) {
      _lastNotification = notification;
      _refreshOperations(space);
    });
    setState(() {
      _isSubscribed = true;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    setState(() {
      _isSubscribed = false;
      _lastNotification = null;
    });
  }

  Future<void> _fetchJoinerInvite() async {
    final inviteId = _joinInviteController.text.trim();
    if (inviteId.isEmpty) {
      _showMessage('Введите идентификатор инвайта');
      return;
    }

    setState(() {
      _joinerBusy = true;
    });

    try {
      final response = await _service.client.invitesFetch(inviteId: inviteId);
      if (!mounted) {
        return;
      }
      setState(() {
        _joinerInvite = response.invite;
      });
      if (response.invite == null) {
        _showMessage('Инвайт не найден или истёк');
      }
    } on Object catch (error) {
      _showMessage('Не удалось получить инвайт: $error');
    } finally {
      if (mounted) {
        setState(() {
          _joinerBusy = false;
        });
      }
    }
  }

  Future<void> _sendJoinerResponse() async {
    final invite = _joinerInvite;
    if (invite == null) {
      return;
    }

    setState(() {
      _joinerBusy = true;
    });

    try {
      final handshake = _randomB64(24);
      final response = await _service.client.invitesRespond(
        inviteId: invite.inviteId,
        joinerHandshakeB64: handshake,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _joinerInvite = response.invite;
        _joinerResponseB64 = handshake;
      });
      _showMessage('Ответ отправлен. Ожидайте финализации владельцем.');
    } on Object catch (error) {
      _showMessage('Не удалось отправить ответ: $error');
    } finally {
      if (mounted) {
        setState(() {
          _joinerBusy = false;
        });
      }
    }
  }

  Future<void> _refreshJoinerInvite() async {
    final invite = _joinerInvite;
    if (invite == null) {
      return;
    }

    setState(() {
      _joinerBusy = true;
    });

    try {
      final response = await _service.client.invitesFetch(inviteId: invite.inviteId);
      if (!mounted) {
        return;
      }
      setState(() {
        _joinerInvite = response.invite;
      });
    } on Object catch (error) {
      _showMessage('Не удалось обновить статус: $error');
    } finally {
      if (mounted) {
        setState(() {
          _joinerBusy = false;
        });
      }
    }
  }

  Future<void> _applyEnvelope() async {
    final invite = _joinerInvite;
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
        plannerId: widget.plannerId,
        plannerSpaceId: data['plannerSpaceId'] as String,
        actorPseudoId: data['actorPseudoId'] as String,
        spaceKeyB64: data['spaceKeyB64'] as String,
        lastSyncedOpIdx: 0,
      );
      await _localStore.saveSpace(space);
      if (!mounted) {
        return;
      }
      setState(() {
        _space = space;
      });
      await _refreshOperations(space);
      _showMessage('Пространство MoniShare подключено');
    } on Object catch (error) {
      _showMessage('Не удалось применить конверт: $error');
    }
  }

  Future<void> _removeSpace() async {
    final space = _space;
    if (space == null) {
      return;
    }

    await _localStore.deleteSpace(space.plannerId);
    _subscription?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _space = null;
      _operations = const [];
      _invites = const [];
      _isSubscribed = false;
      _lastNotification = null;
    });
    _showMessage('Пространство отключено локально');
  }

  Widget _buildSpaceCard(BuildContext context) {
    final space = _space;
    if (space == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MoniShare не настроен', style: context.text.titleLarge),
              const SizedBox(height: AppSpace.s8),
              Text(
                'Создайте пространство чтобы публиковать операции из этого планнера или подключитесь по приглашению.',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: AppSpace.s12),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _ownerBusy ? null : _ensureSpace,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Создать пространство'),
                  ),
                  const SizedBox(width: AppSpace.s12),
                  OutlinedButton.icon(
                    onPressed: _joinerBusy ? null : _fetchJoinerInvite,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Подключиться по инвайту'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s12),
              _buildJoinerFields(),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Пространство активировано', style: context.text.titleLarge),
            const SizedBox(height: AppSpace.s8),
            SelectableText('Space ID: ${space.plannerSpaceId}', style: context.text.bodyMedium),
            SelectableText('Actor: ${space.actorPseudoId}', style: context.text.bodyMedium),
            SelectableText('Space key (base64): ${space.spaceKeyB64}',
                style: context.text.bodySmall?.copyWith(color: context.color.outline)),
            if (_lastNotification != null) ...[
              const SizedBox(height: AppSpace.s8),
              Text(
                'Последнее уведомление: idx ${_lastNotification!.lastOpIdx} '
                '(${_lastNotification!.batchSize} операций)',
                style: context.text.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpace.s12),
            Wrap(
              spacing: AppSpace.s12,
              runSpacing: AppSpace.s8,
              children: [
                FilledButton.icon(
                  onPressed: _ownerBusy ? null : _appendSnapshot,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Опубликовать снимок'),
                ),
                OutlinedButton.icon(
                  onPressed: _ownerBusy ? null : () => _refreshOperations(space),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Обновить операции'),
                ),
                OutlinedButton.icon(
                  onPressed: _ownerBusy ? null : _createInvite,
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Создать инвайт'),
                ),
                OutlinedButton.icon(
                  onPressed: _ownerBusy ? null : _refreshInvites,
                  icon: const Icon(Icons.list_alt_rounded),
                  label: const Text('Обновить инвайты'),
                ),
                TextButton.icon(
                  onPressed: _removeSpace,
                  icon: const Icon(Icons.link_off),
                  label: const Text('Отключить локально'),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s12),
            SwitchListTile.adaptive(
              value: _isSubscribed,
              onChanged: (value) {
                if (value) {
                  _subscribe();
                } else {
                  _unsubscribe();
                }
              },
              title: const Text('Подписка на обновления'),
              subtitle: const Text('Получать уведомления о новых операциях в реальном времени'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _joinInviteController,
          decoration: const InputDecoration(
            labelText: 'ID инвайта',
            hintText: 'Например, INV-123...',
          ),
        ),
        const SizedBox(height: AppSpace.s8),
        Wrap(
          spacing: AppSpace.s12,
          runSpacing: AppSpace.s8,
          children: [
            FilledButton.icon(
              onPressed: _joinerBusy ? null : _fetchJoinerInvite,
              icon: const Icon(Icons.search),
              label: const Text('Получить инвайт'),
            ),
            OutlinedButton.icon(
              onPressed: _joinerBusy || _joinerInvite == null ? null : _sendJoinerResponse,
              icon: const Icon(Icons.reply),
              label: const Text('Отправить ответ'),
            ),
            OutlinedButton.icon(
              onPressed: _joinerBusy || _joinerInvite == null ? null : _refreshJoinerInvite,
              icon: const Icon(Icons.update),
              label: const Text('Проверить статус'),
            ),
            OutlinedButton.icon(
              onPressed:
                  _joinerBusy || _joinerInvite?.encryptedEnvelopeB64 == null ? null : _applyEnvelope,
              icon: const Icon(Icons.download_done),
              label: const Text('Применить конверт'),
            ),
          ],
        ),
        if (_joinerInvite != null) ...[
          const SizedBox(height: AppSpace.s12),
          _buildJoinerStatusCard(),
        ],
      ],
    );
  }

  Widget _buildJoinerStatusCard() {
    final invite = _joinerInvite!;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpace.s8),
        color: context.color.surfaceContainerHighest.withOpacity(0.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Инвайт ${invite.inviteId}', style: context.text.titleMedium),
            const SizedBox(height: AppSpace.s4),
            Text('Статус: ${invite.state.name}', style: context.text.bodyMedium),
            if (invite.ownerHandshakeB64 != null) ...[
              const SizedBox(height: AppSpace.s4),
              SelectableText('Handshake владельца: ${invite.ownerHandshakeB64!}',
                  style: context.text.bodySmall),
            ],
            if (_joinerResponseB64 != null) ...[
              const SizedBox(height: AppSpace.s4),
              SelectableText('Ваш ответ: $_joinerResponseB64', style: context.text.bodySmall),
            ],
            if (invite.finalHandshakeB64 != null) ...[
              const SizedBox(height: AppSpace.s4),
              SelectableText('Финальный handshake: ${invite.finalHandshakeB64!}',
                  style: context.text.bodySmall),
            ],
            if (invite.encryptedEnvelopeB64 != null) ...[
              const SizedBox(height: AppSpace.s8),
              Text('Доступен зашифрованный конверт. Нажмите «Применить конверт».',
                  style: context.text.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOperationsSection() {
    if (_operations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s16),
          child: Text('Операции ещё не загружены', style: context.text.bodyMedium),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Журнал операций (${_operations.length})',
                style: context.text.titleLarge),
            const SizedBox(height: AppSpace.s12),
            ..._operations.map(_buildOperationTile),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationTile(OperationRecord op) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpace.s4),
      child: ListTile(
        title: Text('Операция #${op.opIdx}', style: context.text.titleMedium),
        subtitle: Text(
          'Актор: ${op.actorPseudoId}\n'
          'Размер: ${op.cipherLen} байт\n'
          'Хэш: ${op.cipherHash}\n'
          'Время сервера: ${op.tsServer.toIso8601String()}',
          style: context.text.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.visibility_outlined),
          tooltip: 'Показать payload',
          onPressed: () => _showOperationPayload(op),
        ),
      ),
    );
  }

  void _showOperationPayload(OperationRecord record) {
    String? decoded;
    try {
      decoded = utf8.decode(base64Decode(record.ciphertextB64));
    } on Object {
      decoded = null;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Операция #${record.opIdx}'),
          content: SingleChildScrollView(
            child: decoded != null
                ? SelectableText(decoded)
                : const Text('Payload не является текстовым содержимым'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть'),
            ),
            if (decoded != null)
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: decoded!));
                  Navigator.of(context).pop();
                  _showMessage('Payload скопирован');
                },
                child: const Text('Скопировать'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInvitesSection() {
    if (_space == null) {
      return const SizedBox.shrink();
    }

    if (_invites.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s16),
          child: Text('Инвайтов пока нет', style: context.text.bodyMedium),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Инвайты', style: context.text.titleLarge),
        const SizedBox(height: AppSpace.s8),
        ..._invites.map(_buildInviteCard),
      ],
    );
  }

  Widget _buildInviteCard(MonishareInviteLocal invite) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SelectableText('ID: ${invite.inviteId}',
                      style: context.text.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Скопировать ID',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: invite.inviteId));
                    _showMessage('ID скопирован');
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s4),
            Text('Создан: ${invite.createdAt.toIso8601String()}',
                style: context.text.bodySmall),
            Text('Статус: ${invite.state.name}', style: context.text.bodyMedium),
            if (invite.expiresAt != null)
              Text('Истекает: ${invite.expiresAt!.toIso8601String()}',
                  style: context.text.bodySmall),
            const SizedBox(height: AppSpace.s8),
            SelectableText('Handshake владельца: ${invite.ownerHandshakeB64}',
                style: context.text.bodySmall),
            if (invite.joinerHandshakeB64 != null)
              SelectableText('Handshake участника: ${invite.joinerHandshakeB64}',
                  style: context.text.bodySmall),
            if (invite.finalHandshakeB64 != null)
              SelectableText('Финальный handshake: ${invite.finalHandshakeB64}',
                  style: context.text.bodySmall),
            if (invite.encryptedEnvelopeB64 != null) ...[
              const SizedBox(height: AppSpace.s4),
              SelectableText('Конверт: ${invite.encryptedEnvelopeB64}',
                  style: context.text.bodySmall),
            ],
            const SizedBox(height: AppSpace.s8),
            Row(
              children: [
                if (invite.state == InviteState.responded &&
                    invite.encryptedEnvelopeB64 == null)
                  FilledButton.icon(
                    onPressed: _ownerBusy ? null : () => _finalizeInvite(invite),
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Финализировать'),
                  ),
                const SizedBox(width: AppSpace.s12),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: invite.ownerHandshakeB64));
                    _showMessage('Handshake владельца скопирован');
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Скопировать handshake'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planner = _planner;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          planner == null ? 'MoniShare' : 'MoniShare · ${planner.name}',
          style: context.text.displaySmall,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSpaceCard(context),
                  const SizedBox(height: AppSpace.s16),
                  if (_space != null) _buildOperationsSection(),
                  const SizedBox(height: AppSpace.s16),
                  _buildInvitesSection(),
                ],
              ),
            ),
    );
  }
}
