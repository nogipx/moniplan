import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monishare/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:monishare/models.dart';

class MonisharePlannerScreen extends StatefulWidget {
  const MonisharePlannerScreen({required this.plannerId, super.key});

  final String plannerId;

  @override
  State<MonisharePlannerScreen> createState() => _MonisharePlannerScreenState();
}

class _MonisharePlannerScreenState extends State<MonisharePlannerScreen> {
  late final TextEditingController _joinInviteController;

  @override
  void initState() {
    super.initState();
    _joinInviteController = TextEditingController();
  }

  @override
  void dispose() {
    _joinInviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MonisharePlannerBloc(
        plannerId: widget.plannerId,
        repository: AppDi.instance.get<MonishareRepository>(),
      )..add(const MonisharePlannerStarted()),
      child: BlocListener<MonisharePlannerBloc, MonisharePlannerState>(
        listenWhen: (previous, current) =>
            previous.message != current.message ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state.message != null && state.message!.isNotEmpty) {
            messenger.showSnackBar(SnackBar(content: Text(state.message!)));
          } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            messenger.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.message != null || state.errorMessage != null) {
            context.read<MonisharePlannerBloc>().add(const MonisharePlannerMessageCleared());
          }
        },
        child: _MonisharePlannerView(joinInviteController: _joinInviteController),
      ),
    );
  }
}

class _MonisharePlannerView extends StatelessWidget {
  const _MonisharePlannerView({required this.joinInviteController});

  final TextEditingController joinInviteController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonisharePlannerBloc, MonisharePlannerState>(
      builder: (context, state) {
        final planner = state.planner;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              planner == null ? 'MoniShare' : 'MoniShare · ${planner.name}',
              style: context.text.displaySmall,
            ),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpace.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSpaceCard(context, state),
                      const SizedBox(height: AppSpace.s16),
                      if (state.space != null) _buildOperationsSection(context, state),
                      const SizedBox(height: AppSpace.s16),
                      _buildInvitesSection(context, state),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSpaceCard(BuildContext context, MonisharePlannerState state) {
    final bloc = context.read<MonisharePlannerBloc>();
    final space = state.space;
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
                    onPressed: state.ownerBusy
                        ? null
                        : () => bloc.add(const MonisharePlannerEnsureSpaceRequested()),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Создать пространство'),
                  ),
                  const SizedBox(width: AppSpace.s12),
                  OutlinedButton.icon(
                    onPressed: state.joinerBusy
                        ? null
                        : () => _onFetchJoinerInvite(context),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Подключиться по инвайту'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s12),
              _buildJoinerFields(context, state),
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
            SelectableText(
              'Space key (base64): ${space.spaceKeyB64}',
              style: context.text.bodySmall?.copyWith(color: context.color.outline),
            ),
            if (state.lastNotification != null) ...[
              const SizedBox(height: AppSpace.s8),
              Text(
                'Последнее уведомление: idx ${state.lastNotification!.lastOpIdx} '
                '(${state.lastNotification!.batchSize} операций)',
                style: context.text.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpace.s12),
            Wrap(
              spacing: AppSpace.s12,
              runSpacing: AppSpace.s8,
              children: [
                FilledButton.icon(
                  onPressed: state.ownerBusy
                      ? null
                      : () => bloc.add(const MonisharePlannerAppendSnapshotRequested()),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Опубликовать снимок'),
                ),
                OutlinedButton.icon(
                  onPressed: state.ownerBusy
                      ? null
                      : () => bloc.add(const MonisharePlannerRefreshOperationsRequested()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Обновить операции'),
                ),
                OutlinedButton.icon(
                  onPressed: state.ownerBusy
                      ? null
                      : () => bloc.add(const MonisharePlannerCreateInviteRequested()),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Создать инвайт'),
                ),
                OutlinedButton.icon(
                  onPressed: state.ownerBusy
                      ? null
                      : () => bloc.add(const MonisharePlannerRefreshInvitesRequested()),
                  icon: const Icon(Icons.list_alt_rounded),
                  label: const Text('Обновить инвайты'),
                ),
                TextButton.icon(
                  onPressed: () => bloc.add(const MonisharePlannerRemoveSpaceRequested()),
                  icon: const Icon(Icons.link_off),
                  label: const Text('Отключить локально'),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s12),
            SwitchListTile.adaptive(
              value: state.isSubscribed,
              onChanged: (value) {
                bloc.add(MonisharePlannerSubscriptionToggled(subscribe: value));
              },
              title: const Text('Подписка на обновления'),
              subtitle: const Text('Получать уведомления о новых операциях в реальном времени'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinerFields(BuildContext context, MonisharePlannerState state) {
    final bloc = context.read<MonisharePlannerBloc>();
    final invite = state.joinerInvite;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: joinInviteController,
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
              onPressed: state.joinerBusy ? null : () => _onFetchJoinerInvite(context),
              icon: const Icon(Icons.search),
              label: const Text('Получить инвайт'),
            ),
            OutlinedButton.icon(
              onPressed: state.joinerBusy || invite == null
                  ? null
                  : () => bloc.add(const MonisharePlannerJoinerRespondRequested()),
              icon: const Icon(Icons.reply),
              label: const Text('Отправить ответ'),
            ),
            OutlinedButton.icon(
              onPressed: state.joinerBusy || invite == null
                  ? null
                  : () => bloc.add(const MonisharePlannerJoinerRefreshRequested()),
              icon: const Icon(Icons.update),
              label: const Text('Проверить статус'),
            ),
            OutlinedButton.icon(
              onPressed: state.joinerBusy || invite?.encryptedEnvelopeB64 == null
                  ? null
                  : () => bloc.add(const MonisharePlannerApplyEnvelopeRequested()),
              icon: const Icon(Icons.download_done),
              label: const Text('Применить конверт'),
            ),
          ],
        ),
        if (invite != null) ...[
          const SizedBox(height: AppSpace.s12),
          _buildJoinerStatusCard(context, state, invite),
        ],
      ],
    );
  }

  Widget _buildJoinerStatusCard(
    BuildContext context,
    MonisharePlannerState state,
    Invite invite,
  ) {
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
            if (state.joinerResponseB64 != null) ...[
              const SizedBox(height: AppSpace.s4),
              SelectableText('Ваш ответ: ${state.joinerResponseB64}',
                  style: context.text.bodySmall),
            ],
            if (invite.finalHandshakeB64 != null) ...[
              const SizedBox(height: AppSpace.s4),
              SelectableText('Финальный handshake: ${invite.finalHandshakeB64!}',
                  style: context.text.bodySmall),
            ],
            if (invite.encryptedEnvelopeB64 != null) ...[
              const SizedBox(height: AppSpace.s8),
              Text(
                'Доступен зашифрованный конверт. Нажмите «Применить конверт».',
                style: context.text.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOperationsSection(BuildContext context, MonisharePlannerState state) {
    if (state.operations.isEmpty) {
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
            Text('Журнал операций (${state.operations.length})',
                style: context.text.titleLarge),
            const SizedBox(height: AppSpace.s12),
            ...state.operations.map((op) => _buildOperationTile(context, op)),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationTile(BuildContext context, OperationRecord op) {
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
          onPressed: () => _showOperationPayload(context, op),
        ),
      ),
    );
  }

  void _showOperationPayload(BuildContext context, OperationRecord record) {
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
            if (decoded != null)
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: decoded!));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Payload скопирован')));
                },
                child: const Text('Скопировать'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInvitesSection(BuildContext context, MonisharePlannerState state) {
    if (state.space == null) {
      return const SizedBox.shrink();
    }

    if (state.invites.isEmpty) {
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
        ...state.invites.map((invite) => _buildInviteCard(context, state, invite)),
      ],
    );
  }

  Widget _buildInviteCard(
    BuildContext context,
    MonisharePlannerState state,
    MonishareInviteLocal invite,
  ) {
    final bloc = context.read<MonisharePlannerBloc>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SelectableText('ID: ${invite.inviteId}', style: context.text.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Скопировать ID',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: invite.inviteId));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('ID скопирован')));
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s4),
            Text('Создан: ${invite.createdAt.toIso8601String()}', style: context.text.bodySmall),
            Text('Статус: ${invite.state.name}', style: context.text.bodyMedium),
            if (invite.expiresAt != null)
              Text('Истекает: ${invite.expiresAt!.toIso8601String()}', style: context.text.bodySmall),
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
                if (invite.state == InviteState.responded && invite.encryptedEnvelopeB64 == null)
                  FilledButton.icon(
                    onPressed: state.ownerBusy
                        ? null
                        : () => bloc.add(
                              MonisharePlannerFinalizeInviteRequested(invite: invite),
                            ),
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Финализировать'),
                  ),
                const SizedBox(width: AppSpace.s12),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: invite.ownerHandshakeB64));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Handshake владельца скопирован')),
                    );
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

  void _onFetchJoinerInvite(BuildContext context) {
    final id = joinInviteController.text.trim();
    context
        .read<MonisharePlannerBloc>()
        .add(MonisharePlannerJoinerInviteFetchRequested(inviteId: id));
  }
}
