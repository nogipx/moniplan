// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/domain/moniplan_domain.dart';
import 'package:moniplan_app/features/monisync/repo/i_manual_monisync_repo.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rpc_dart/logger.dart';
import 'package:share_plus/share_plus.dart';

import '../models/backup_info.dart';

part 'components/backup_action_card.dart';
part 'components/backup_info_sheet.dart';
part 'components/csv_export_dialog.dart';
part 'components/password_dialog.dart';
part 'components/protection_selector.dart';

class MonisyncScreen extends StatefulWidget {
  const MonisyncScreen({super.key});

  @override
  State<MonisyncScreen> createState() => _MonisyncScreenState();
}

class _MonisyncScreenState extends State<MonisyncScreen> {
  IMonisyncRepo? _monisyncRepo;
  final IPlannerRepo _plannerRepo = AppDi.instance.getPlannerRepo();
  final _log = RpcLogger('MoniSync');

  List<Planner> _planners = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlanners();
  }

  Future<void> _loadPlanners() async {
    _monisyncRepo = await AppDi.instance.getMonisyncRepo();

    setState(() {
      _isLoading = true;
    });

    try {
      final planners = await _plannerRepo.getPlanners();
      setState(() {
        _planners = planners;
      });
    } catch (e) {
      _log.error('Ошибка загрузки планеров', error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monisync', style: context.text.displaySmall), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Резервное копирование',
                        style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      BackupActionCard(
                        title: 'Создать резервную копию',
                        subtitle: 'Сохранить все ваши данные для будущего восстановления',
                        icon: Icons.backup_rounded,
                        iconColor: Colors.blue,
                        onTap: _exportFilePicker,
                      ),
                      const SizedBox(height: 12),
                      BackupActionCard(
                        title: 'Восстановить из резервной копии',
                        subtitle: 'Восстановить данные из ранее созданного бэкапа',
                        icon: Icons.restore_rounded,
                        iconColor: Colors.orange,
                        onTap: _importFilePicker,
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: 12),
                        BackupActionCard(
                          title: 'Скачать базу',
                          subtitle: '',
                          icon: Icons.raw_on,
                          iconColor: Colors.red,
                          onTap: _downloadDb,
                        ),
                        const SizedBox(height: 12),
                        BackupActionCard(
                          title: 'Вставить базу',
                          subtitle: '',
                          icon: Icons.add_to_home_screen,
                          iconColor: Colors.red,
                          onTap: _importDb,
                        ),
                      ],
                      const SizedBox(height: 36),
                      Text(
                        'Экспорт данных',
                        style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'О резервных копиях',
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Регулярно создавайте резервные копии ваших данных, чтобы избежать их потери. '
                              'Вы можете защитить свои данные паролем для дополнительной безопасности.',
                              style: context.text.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Экспорт в CSV позволяет вам анализировать ваши платежи в Excel, Google Таблицах и других программах.',
                              style: context.text.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Future<void> _exportFilePicker() async {
    final password = await PasswordDialog.show(context, isExport: true);
    if (password == null) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final token = await _monisyncRepo?.exportData(now: now, password: password);

      if (token != null) {
        final bytes = utf8.encode(token);
        final fileName = _monisyncRepo?.createBackupFileName(now) ?? 'moniplan_backup.moniplan';

        setState(() => _isLoading = false);

        // Показываем диалог выбора действия
        final shareOption = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: context.theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder:
              (context) => _buildExportOptionsSheet(
                context,
                title: 'Резервная копия',
                saveText: 'Файл будет сохранен в выбранном месте',
                shareText: 'Отправить через мессенджер или почту',
              ),
        );

        if (shareOption == null) return; // Пользователь закрыл диалог

        setState(() => _isLoading = true);

        if (shareOption) {
          // Поделиться файлом
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$fileName');
          await tempFile.writeAsBytes(bytes);

          // Импортируем Share из пакета share_plus
          final xFile = XFile(tempFile.path, mimeType: 'application/octet-stream');
          await Share.shareXFiles(
            [xFile],
            subject: 'Резервная копия Moniplan',
            text: 'Резервная копия Moniplan от ${DateFormat('dd.MM.yyyy').format(now)}',
          );

          showToast('Резервная копия с паролем отправлена');
        } else {
          // Сохранить на устройстве
          final result = await FilePicker.platform.saveFile(
            dialogTitle: 'Сохранение резервной копии',
            fileName: fileName,
            bytes: bytes,
          );

          if (result != null) {
            await File(result).writeAsBytes(bytes);

            showToast('Резервная копия с паролем сохранена');
          }
        }
      }
    } catch (error) {
      _log.error('Ошибка экспорта', error: error);
      showToast('Ошибка при экспорте данных');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadDb() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final bytes = await AppDb.instance.exportBytes();
      final fileName = "${_monisyncRepo?.createBackupFileName(now)}.db";

      setState(() => _isLoading = false);

      // Показываем диалог выбора действия
      final shareOption = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: context.theme.colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder:
            (context) => _buildExportOptionsSheet(
              context,
              title: 'Резервная копия',
              saveText: 'Файл будет сохранен в выбранном месте',
              shareText: 'Отправить через мессенджер или почту',
            ),
      );

      if (shareOption == null) return; // Пользователь закрыл диалог

      setState(() => _isLoading = true);

      if (shareOption) {
        // Поделиться файлом
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(bytes);

        // Импортируем Share из пакета share_plus
        final xFile = XFile(tempFile.path, mimeType: 'application/octet-stream');
        await Share.shareXFiles(
          [xFile],
          subject: 'Резервная копия Moniplan',
          text: 'Резервная копия Moniplan от ${DateFormat('dd.MM.yyyy').format(now)}',
        );

        showToast('Резервная копия с паролем отправлена');
      } else {
        // Сохранить на устройстве
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Сохранение резервной копии',
          fileName: fileName,
          bytes: bytes,
        );

        if (result != null) {
          await File(result).writeAsBytes(bytes);

          showToast('Резервная копия с паролем сохранена');
        }
      }
    } catch (error) {
      _log.error('Ошибка экспорта', error: error);
      showToast('Ошибка при экспорте данных');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Показывает нижнюю шторку с выбором способа экспорта
  Widget _buildExportOptionsSheet(
    BuildContext context, {
    String title = 'Выберите действие',
    String saveText = 'Файл будет сохранен в выбранном месте',
    String shareText = 'Отправить через мессенджер или почту',
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title,
                style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              elevation: 0,
              color: context.theme.colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(false),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.save_alt_rounded,
                          color: context.theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Сохранить на устройстве',
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              saveText,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: context.theme.colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(true),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.share_rounded, color: context.theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Поделиться',
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shareText,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSuccessPasswordBackupDialog() {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Экспорт завершен'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 48, color: Colors.green),
                const SizedBox(height: 16),
                const Text('Резервная копия успешно сохранена и защищена паролем.'),
                const SizedBox(height: 8),
                Text(
                  'Не забудьте пароль, иначе вы не сможете восстановить данные!',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            actions: [
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ОК')),
            ],
          ),
    );
  }

  Future<void> _importFilePicker() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final bytes = result.files.single.bytes;
    final token = utf8.decode(bytes!.toList());
    final password = await PasswordDialog.show(context, isExport: true);
    if (password == null) return;
    final backupInfo = await _monisyncRepo?.readBackupInfo(token: token, password: password);

    if (backupInfo == null) {
      showToast('Не удалось прочитать информацию о файле');
      return;
    }

    // Показываем информацию о файле и запрашиваем подтверждение
    final shouldImport = await BackupInfoSheet.show(context, backupInfo);
    if (!shouldImport) return;

    setState(() => _isLoading = true);

    try {
      await _monisyncRepo?.importData(token: token, password: password);
      showToast('Данные успешно импортированы');
    } catch (e) {
      _log.error('Ошибка импорта', error: e);
      await _showImportError();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importDb() async {
    final result = await FilePicker.platform.pickFiles();
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    setState(() => _isLoading = true);

    try {
      await AppDb.instance.overwriteWithBytes(bytes: bytes);
      showToast('Данные успешно импортированы');
    } catch (e) {
      _log.error('Ошибка импорта', error: e);
      await _showImportError();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showImportError() {
    String errorMessage = 'Не удалось расшифровать файл. Проверьте правильность введенного пароля.';

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ошибка импорта'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(errorMessage),
              ],
            ),
            actions: [
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ОК')),
            ],
          ),
    );
  }
}
