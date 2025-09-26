import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/turn_relay_bloc.dart';

class TurnRelayChatScreen extends StatefulWidget {
  const TurnRelayChatScreen({
    super.key,
    this.localAuthorId = 'local',
  });

  final String localAuthorId;

  @override
  State<TurnRelayChatScreen> createState() => _TurnRelayChatScreenState();
}

class _TurnRelayChatScreenState extends State<TurnRelayChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  Object? _lastError;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSend(TurnRelayState state) {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    context.read<TurnRelayBloc>().add(
          TurnRelayChatMessageSubmitted(
            authorId: widget.localAuthorId,
            text: text,
          ),
        );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TurnRelayBloc, TurnRelayState>(
      listenWhen: (previous, current) =>
          previous.chatMessages.length != current.chatMessages.length ||
          previous.error != current.error,
      listener: (context, state) {
        if (state.chatMessages.length != _lastMessageCount) {
          _lastMessageCount = state.chatMessages.length;
          _scrollToBottom();
        }

        if (state.error != null && state.error != _lastError) {
          _lastError = state.error;
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final canSend = state.status == TurnRelayStatus.peerReady &&
            state.isChatReady &&
            !state.isSendingChatMessage;
        final isInputEnabled =
            state.status == TurnRelayStatus.peerReady && state.isChatReady;
        final messages = state.chatMessages;

        return Scaffold(
          appBar: AppBar(
            title: const Text('TURN relay чат'),
          ),
          body: Column(
            children: [
              _TurnRelayChatStatus(state: state),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSelf = message.authorId == widget.localAuthorId;
                    final sentAt = DateFormat.Hm().format(
                      message.sentAt.toLocal(),
                    );
                    final alignment =
                        isSelf ? Alignment.centerRight : Alignment.centerLeft;
                    final bubbleColor = isSelf
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceVariant;
                    final textColor = isSelf
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant;

                    return Align(
                      alignment: alignment,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Column(
                          crossAxisAlignment: isSelf
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.authorId,
                              style: theme.textTheme.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.text,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sentAt,
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: isInputEnabled,
                        textInputAction: TextInputAction.send,
                        decoration: const InputDecoration(
                          hintText: 'Введите сообщение',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _handleSend(state),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: canSend ? () => _handleSend(state) : null,
                      child: state.isSendingChatMessage
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TurnRelayChatStatus extends StatelessWidget {
  const _TurnRelayChatStatus({required this.state});

  final TurnRelayState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = state.pendingConnectRequest;
    final statusText = _statusLabel(state.status);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статус: $statusText',
            style: theme.textTheme.bodyMedium,
          ),
          if (state.serverAddress != null && state.serverPort != null)
            Text(
              'Релей: ${state.serverAddress!.address}:${state.serverPort}',
              style: theme.textTheme.bodySmall,
            ),
          if (state.peerAddress != null && state.peerPort != null)
            Text(
              'Пир: ${state.peerAddress!.address}:${state.peerPort}',
              style: theme.textTheme.bodySmall,
            ),
          Text(
            state.isChatReady ? 'Чат готов' : 'Чат не готов',
            style: theme.textTheme.bodySmall,
          ),
          if (pending != null)
            Text(
              'Входящий запрос от ${pending.peerAddress.address}:${pending.peerPort}',
              style: theme.textTheme.bodySmall,
            ),
          if (state.error != null)
            Text(
              'Ошибка: ${state.error}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }

  String _statusLabel(TurnRelayStatus status) {
    switch (status) {
      case TurnRelayStatus.initial:
        return 'не подключено';
      case TurnRelayStatus.connectingRelay:
        return 'подключение к релею';
      case TurnRelayStatus.relayReady:
        return 'релей готов';
      case TurnRelayStatus.connectingPeer:
        return 'подключение к пиру';
      case TurnRelayStatus.peerReady:
        return 'пир подключен';
      case TurnRelayStatus.disconnecting:
        return 'отключение';
    }
  }
}
