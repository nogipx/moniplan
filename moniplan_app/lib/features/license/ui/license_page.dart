// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:licensify/licensify.dart';
import 'package:moniplan_app/features/license/bloc/_index.dart';
import 'package:moniplan_app/features/license/ui/components/_index.dart';
import 'package:moniplan_app/features/license/ui/license_generator_page.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Управление лицензией', style: context.text.displaySmall),
        actions: [
          IconButton(
            onPressed: () => context.read<LicenseBloc>().add(const LicenseLoadedEvent()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить статус',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const LicenseGeneratorPage()));
            },
            icon: const Icon(Icons.build),
            tooltip: 'Генератор лицензий',
          ),
        ],
      ),
      body: BlocConsumer<LicenseBloc, LicenseState>(
        listener: (context, state) {
          if (state is LicenseErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is LicenseInitialState || state is LicenseLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LicenseNotFoundState) {
            return _LicenseNotFoundView();
          }

          if (state is LicenseValidState) {
            return _LicenseView(license: state.license, isValid: true, isExpired: false);
          }

          if (state is LicenseExpiredState) {
            return _LicenseView(
              license: state.license,
              isValid: false,
              isExpired: true,
              errorMessage: 'Необходимо продлить лицензию',
            );
          }

          if (state is LicenseInvalidState) {
            return _LicenseView(
              license: state.license!,
              isValid: false,
              isExpired: false,
              errorMessage: state.message,
            );
          }

          // Для других состояний показываем сообщение об ошибке
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Ошибка состояния лицензии: ${state.runtimeType}'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.read<LicenseBloc>().add(const LicenseLoadedEvent()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Обновить'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LicenseNotFoundView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.vpn_key_off_outlined, size: 120, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Лицензия не найдена',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавьте лицензию, чтобы разблокировать все функции приложения',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _uploadLicense(context),
              icon: const Icon(Icons.add),
              label: const Text('Загрузить лицензию'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseView extends StatelessWidget {
  final License license;
  final bool isValid;
  final bool isExpired;
  final String? errorMessage;

  const _LicenseView({
    required this.license,
    required this.isValid,
    required this.isExpired,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Карточка с информацией о лицензии
          LicenseCard(
            license: license,
            isValid: isValid,
            isExpired: isExpired,
            errorMessage: errorMessage,
          ),

          // Кнопки действий
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () => _uploadLicense(context, isUpdate: true),
                icon: const Icon(Icons.update),
                label: const Text('Обновить'),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirmDeleteLicense(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Удалить'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _uploadLicense(BuildContext context, {bool isUpdate = false}) async {
  try {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path;
      if (path == null || !path.endsWith('.licensify')) {
        return;
      }

      final file = File(path);
      final bytes = await file.readAsBytes();

      if (isUpdate) {
        context.read<LicenseBloc>().add(LicenseUpdatedEvent(licenseBytes: bytes));
      } else {
        context.read<LicenseBloc>().add(LicenseAddedEvent(licenseBytes: bytes));
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось загрузить файл'), backgroundColor: Colors.red),
    );
  }
}

Future<void> _confirmDeleteLicense(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Удаление лицензии'),
          content: const Text(
            'Вы действительно хотите удалить лицензию? '
            'Это действие нельзя отменить.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
  );

  if (confirmed == true) {
    if (context.mounted) {
      context.read<LicenseBloc>().add(const LicenseDeletedEvent());
    }
  }
}
