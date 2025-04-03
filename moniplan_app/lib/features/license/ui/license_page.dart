// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_app/features/license/bloc/_index.dart';
import 'package:moniplan_app/features/license/ui/components/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Управление лицензией', style: context.text.displaySmall)),
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
            return _LicenseView(
              license: state.license,
              isValid: true,
              isExpired: false,
              isWrongDevice: false,
            );
          }

          if (state is LicenseExpiredState) {
            return _LicenseView(
              license: state.license,
              isValid: false,
              isExpired: true,
              isWrongDevice: false,
              errorMessage: 'Необходимо продлить лицензию',
            );
          }

          if (state is LicenseWrongDeviceState) {
            return _LicenseView(
              license: state.license,
              isValid: false,
              isExpired: false,
              isWrongDevice: true,
              errorMessage: 'Лицензия привязана к другому устройству',
            );
          }

          if (state is LicenseInvalidState) {
            return _LicenseView(
              license: state.license!,
              isValid: false,
              isExpired: false,
              isWrongDevice: false,
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
        child: ListView(
          children: [
            const Icon(Icons.vpn_key_off_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Лицензия не найдена',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавьте лицензию, чтобы разблокировать все функции приложения',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Как получить лицензию:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text('1. Нажмите "Запросить лицензию"'),
                    Text('2. Поделитесь файлом запроса (.mlr)'),
                    Text('3. Дождитесь получения файла лицензии (.licensify)'),
                    Text('4. Загрузите полученную лицензию в приложение'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _uploadLicense(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Загрузить лицензию'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _requestLicense(context),
                  icon: const Icon(Icons.request_page),
                  label: const Text('Запросить лицензию'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
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
  final bool isWrongDevice;
  final String? errorMessage;

  const _LicenseView({
    required this.license,
    required this.isValid,
    required this.isExpired,
    this.isWrongDevice = false,
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
            isWrongDevice: isWrongDevice,
            errorMessage: errorMessage,
          ),

          // Сообщение об истечении лицензии
          if (isExpired) ...[
            const SizedBox(height: 24),
            const Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              color: Color(0xFFFFF3E0), // light orange background
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Срок действия лицензии истек',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepOrange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Для продолжения работы с полным функционалом:'),
                    Text('1. Запросите новую лицензию'),
                    Text('2. Загрузите полученную лицензию'),
                  ],
                ),
              ),
            ),
          ],

          // Кнопки действий
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              OutlinedButton.icon(
                onPressed: () => _uploadLicense(context, isUpdate: true),
                icon: const Icon(Icons.update),
                label: const Text('Обновить'),
              ),
              OutlinedButton.icon(
                onPressed: () => _requestLicense(context),
                icon: const Icon(Icons.request_page),
                label: const Text('Запросить новую'),
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: 'Выберите файл лицензии',
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path;
      if (path == null || !path.endsWith('.licensify')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Выбран некорректный файл. Файл должен иметь расширение .licensify'),
            backgroundColor: Colors.red,
          ),
        );
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
      SnackBar(
        content: Text('Не удалось загрузить файл: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
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

Future<void> _requestLicense(BuildContext context) async {
  try {
    // Показываем диалог с индикатором загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            title: Text('Подготовка запроса'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Пожалуйста, подождите...'),
              ],
            ),
          ),
    );

    // Получаем репозиторий для работы с лицензиями
    final licenseRepo = AppDi.instance.get<IMoniplanLicenseRepo>();

    // Генерируем запрос лицензии
    final requestBytes = await licenseRepo.generateLicenseRequest();

    // Создаем временный файл для запроса
    final tempDir = await getTemporaryDirectory();
    final dateString = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final fileName = 'moniplan_license_request_$dateString.mlr';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(requestBytes);

    // Закрываем диалог с индикатором загрузки
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Показываем запрос на экспорт файла
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Запрос лицензии MoniPlan',
      text: 'Отправьте этот файл для получения лицензии приложения MoniPlan',
    );
  } catch (e, trace) {
    AppLog(
      'LicensePage',
    ).error('Ошибка при создании запроса лицензии: ${e.toString()}', error: e, trace: trace);

    // Закрываем диалог с индикатором загрузки, если он еще открыт
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Показываем сообщение об ошибке
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при создании запроса лицензии: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
