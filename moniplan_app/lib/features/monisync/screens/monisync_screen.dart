// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';

class MonisyncScreen extends StatefulWidget {
  const MonisyncScreen({super.key});

  @override
  State<MonisyncScreen> createState() => _MonisyncScreenState();
}

class _MonisyncScreenState extends State<MonisyncScreen> {
  final _monisyncRepo = AppDi.instance.getMonisyncRepo();
  final _plannerRepo = AppDi.instance.getPlannerRepo();
  final _log = AppLog('MoniSync');

  List<Planner> _planners = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlanners();
  }

  Future<void> _loadPlanners() async {
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
      appBar: AppBar(title: Text('Экспорт и импорт данных', style: context.text.displaySmall)),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _exportFilePicker,
                        icon: const Icon(Icons.backup),
                        label: const Text('Экспорт резервной копии'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _exportCSVPicker,
                        icon: const Icon(Icons.table_chart),
                        label: const Text('Экспорт в CSV'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _importFilePicker,
                        icon: const Icon(Icons.restore),
                        label: const Text('Импорт резервной копии'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Экспорт в CSV позволяет выгрузить данные о платежах в формате, который можно открыть в Excel или Google Таблицах. При экспорте для платежей без категорий будут предложены категории на основе искусственного интеллекта.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  // Future<void> _exportShareFile() async {
  //   final now = DateTime.now();
  //   final exportResult = await _monisyncRepo.exportDataToFile(now: now);
  //
  //   if (exportResult != null) {
  //     try {
  //       final bytes = await exportResult.file.readAsBytes();
  //       final xfile = XFile.fromData(bytes);
  //
  //       final result = Share.shareXFiles(
  //         [xfile],
  //         subject: 'Share Moniplan data',
  //       );
  //       print(result);
  //     } on Object catch (error, trace) {
  //       _log.error('Failed to export', error: error, trace: trace);
  //       rethrow;
  //     }
  //   }
  // }

  Future<void> _exportFilePicker() async {
    final now = DateTime.now();
    final exportResult = await _monisyncRepo.exportDataToFile(now: now);

    if (exportResult != null) {
      try {
        final bytes = exportResult.file.readAsBytesSync();

        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Сохранение резервной копии',
          fileName: _monisyncRepo.getBackupFileName(now),
          bytes: bytes,
        );

        if (result != null) {
          final saveFile = await File(result).writeAsBytes(bytes);
          showToast('Резервная копия сохранена: ${saveFile.path}');
        }
      } on Object catch (error, trace) {
        _log.error('Ошибка экспорта', error: error, trace: trace);
        showToast('Ошибка при экспорте данных');
        rethrow;
      }
    }
  }

  Future<void> _exportCSVPicker() async {
    if (_planners.isEmpty) {
      showToast('Нет доступных планеров для экспорта');
      return;
    }

    // Если есть только один планер, используем его
    if (_planners.length == 1) {
      await _exportPlannerToCSV(_planners.first.id);
      return;
    }

    // Если планеров несколько, показываем диалог выбора
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Выберите планер для экспорта'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _planners.length,
                itemBuilder: (context, index) {
                  final planner = _planners[index];
                  return ListTile(
                    title: Text(planner.name),
                    subtitle: Text('${planner.payments.length} платежей'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _exportPlannerToCSV(planner.id);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
            ],
          ),
    );
  }

  Future<void> _exportPlannerToCSV(String plannerId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Показываем диалог с опциями экспорта
      final usePredictedCategories =
          await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Настройки экспорта'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Использовать ИИ для предсказания категорий платежей без категорий?',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Это может занять некоторое время, но позволит получить более полные данные.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Без предсказаний'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('С предсказаниями'),
                    ),
                  ],
                ),
          ) ??
          true; // По умолчанию используем предсказания

      // Экспортируем данные
      final exportResult = await _monisyncRepo.exportPaymentsToCSV(
        plannerId: plannerId,
        usePredictedCategories: usePredictedCategories,
      );

      if (exportResult != null) {
        final bytes = exportResult.file.readAsBytesSync();
        final now = DateTime.now();
        final fileName = 'payments_${DateFormat('yyyyMMdd').format(now)}.csv';

        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Сохранение CSV файла',
          fileName: fileName,
          bytes: bytes,
        );

        if (result != null) {
          final saveFile = await File(result).writeAsBytes(bytes);
          showToast('CSV файл сохранен: ${saveFile.path}');
        }
      }
    } catch (e, stack) {
      _log.error('Ошибка экспорта в CSV', error: e, trace: stack);
      showToast('Ошибка при экспорте данных в CSV');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final filePath = result.files.single.path!;
      try {
        await _monisyncRepo.importDataFromFile(filePath: filePath);
        showToast('Данные успешно импортированы');
        await _loadPlanners(); // Перезагружаем планеры после импорта
      } catch (e) {
        _log.error('Ошибка импорта', error: e);
        showToast('Ошибка при импорте данных');
      }
    } else {
      // User canceled the picker
    }
  }
}
