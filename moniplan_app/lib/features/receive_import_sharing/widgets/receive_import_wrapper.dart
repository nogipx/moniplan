// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/monisync/screens/monisync_screen.dart';
import 'package:moniplan_app/features/receive_import_sharing/bloc/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';

class ReceiveImportWrapper extends StatefulWidget {
  final Widget child;

  const ReceiveImportWrapper({super.key, required this.child});

  @override
  State<ReceiveImportWrapper> createState() => _ReceiveImportWrapperState();
}

class _ReceiveImportWrapperState extends State<ReceiveImportWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<ReceiveImportSharingBloc>().add(ReceiveImportStartReceiveEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiveImportSharingBloc, ReceiveImportState>(
      child: widget.child,
      listenWhen: (prev, curr) {
        return curr is ReceiveImportDecisionState || curr is ReceiveImportResultState;
      },
      listener: (context, state) async {
        if (state is ReceiveImportDecisionState) {
          final decision = await _onDataReceived(context, state);
          if (decision != null) {
            context.read<ReceiveImportSharingBloc>().add(decision);
          }
        }
        if (state is ReceiveImportResultState) {
          _onImportResult(context, state);
        }
      },
    );
  }

  Future<ReceiveImportOnDecisionEvent?> _onDataReceived(
    BuildContext context,
    ReceiveImportDecisionState state,
  ) async {
    if (!context.mounted) {
      return null;
    }

    final backup = state.toImportBackups.firstOrNull;
    if (backup == null) {
      showToast('Некорректный файл резервной копии');
      return null;
    }

    // Используем BackupInfoSheet для отображения информации и запроса подтверждения
    final shouldImport = await BackupInfoSheet.show(context, backup);

    // Если пользователь согласился на импорт и бэкап защищен паролем, запрашиваем пароль
    String? password;
    if (shouldImport) {
      password = await PasswordDialog.show(context, isExport: false);
      if (password == null) {
        return ReceiveImportOnDecisionEvent(shouldImport: false, acceptedBackup: backup);
      }
    }

    return ReceiveImportOnDecisionEvent(
      shouldImport: shouldImport,
      acceptedBackup: backup,
      password: password,
    );
  }

  Future<void> _onImportResult(BuildContext context, ReceiveImportResultState state) async {
    if (!context.mounted) {
      return;
    }

    switch (state.result) {
      case ReceiveImportResult.imported:
        showSuccessDialog(context, 'Данные успешно импортированы');
        break;
      case ReceiveImportResult.fileNotFound:
        showToast('Файл не найден');
        break;
      case ReceiveImportResult.error:
        showErrorDialog(
          context,
          'Ошибка импорта',
          'Не удалось импортировать данные. Возможно, файл поврежден или введен неверный пароль.',
        );
        break;
      case ReceiveImportResult.cancelled:
        // Пользователь отменил - ничего не делаем
        break;
    }
  }

  // Показывает диалог успешного импорта
  Future<void> showSuccessDialog(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Импорт завершен'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 48, color: context.theme.colorScheme.primary),
                SizedBox(height: 16),
                Text(message),
              ],
            ),
            actions: [
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text('ОК')),
            ],
          ),
    );
  }

  // Показывает диалог ошибки
  Future<void> showErrorDialog(BuildContext context, String title, String message) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: context.theme.colorScheme.error),
                SizedBox(height: 16),
                Text(message),
              ],
            ),
            actions: [
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text('ОК')),
            ],
          ),
    );
  }
}
