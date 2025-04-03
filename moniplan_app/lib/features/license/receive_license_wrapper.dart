// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/license/bloc/_index.dart';
import 'package:moniplan_app/features/receive_import_sharing/bloc/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Обертка для обработки импорта лицензии через диплинк
class ReceiveLicenseWrapper extends StatefulWidget {
  final Widget child;

  const ReceiveLicenseWrapper({super.key, required this.child});

  @override
  State<ReceiveLicenseWrapper> createState() => _ReceiveLicenseWrapperState();
}

class _ReceiveLicenseWrapperState extends State<ReceiveLicenseWrapper> {
  final _log = AppLog('ReceiveLicenseWrapper');

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiveImportSharingBloc, ReceiveImportState>(
      child: widget.child,
      listenWhen: (prev, curr) {
        return curr is ReceiveImportLicenseState;
      },
      listener: (context, state) async {
        if (state is ReceiveImportLicenseState) {
          await _handleLicenseFile(context, state.licenseFile);
        }
      },
    );
  }

  /// Обрабатывает файл лицензии
  Future<void> _handleLicenseFile(BuildContext context, SharedMediaFile licenseFile) async {
    if (!context.mounted) return;

    try {
      final file = File(licenseFile.path);
      if (!await file.exists()) {
        showToast('Файл лицензии не найден');
        return;
      }

      // Подтвердим импорт файла
      final confirmImport = await _showConfirmDialog(context);
      if (!confirmImport) return;

      // Загружаем байты файла
      final bytes = await file.readAsBytes();

      // Добавляем или обновляем лицензию
      LicenseEvent event;

      // Проверяем, существует ли уже лицензия
      final licenseRepo = AppDi.instance.get<IMoniplanLicenseRepo>();
      final hasLicense = await licenseRepo.getCurrentLicense() != null;

      if (hasLicense) {
        // Если лицензия уже существует, обновляем её
        event = LicenseUpdatedEvent(licenseBytes: bytes);
      } else {
        // Если лицензии ещё нет, добавляем новую
        event = LicenseAddedEvent(licenseBytes: bytes);
      }

      context.read<LicenseBloc>().add(event);

      // Показываем сообщение об успехе
      showToast('Файл лицензии импортирован');
    } catch (e, trace) {
      _log.error('Ошибка обработки файла лицензии', error: e, trace: trace);
      if (context.mounted) {
        showErrorDialog(
          context,
          'Ошибка импорта',
          'Не удалось импортировать лицензию. Возможно, файл поврежден или имеет неверный формат.',
        );
      }
    }
  }

  /// Запрашивает подтверждение импорта лицензии
  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Импорт лицензии'),
                content: const Text(
                  'Вы собираетесь импортировать файл лицензии. Если у вас уже есть лицензия, она будет заменена. Продолжить?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Импортировать'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// Показывает диалог ошибки
  Future<void> showErrorDialog(BuildContext context, String title, String message) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: context.theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
            actions: [
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ОК')),
            ],
          ),
    );
  }
}
