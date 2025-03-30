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
  IMonisyncRepo? _monisyncRepo;
  final IPlannerRepo _plannerRepo = AppDi.instance.getPlannerRepo();
  final _log = AppLog('MoniSync');

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

  // Улучшенный UI для ввода пароля с дополнительными функциями
  Future<String?> _showPasswordDialog(BuildContext context, {bool isExport = true}) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool showPassword = false;

    return showDialog<String>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    isExport ? 'Защита экспорта' : 'Ввод пароля',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isExport
                              ? 'Создайте пароль для защиты ваших данных'
                              : 'Введите пароль для расшифровки файла',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: controller,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: IconButton(
                              icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => showPassword = !showPassword),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) {
                            if (isExport && (value == null || value.length < 6)) {
                              return 'Пароль должен содержать минимум 6 символов';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        if (isExport)
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Запомните этот пароль! Без него вы не сможете восстановить данные.',
                                    style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Отмена')),
                    ElevatedButton(
                      onPressed: () {
                        if (!isExport || formKey.currentState!.validate()) {
                          Navigator.of(context).pop(controller.text);
                        }
                      },
                      child: Text('Подтвердить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _exportFilePicker() async {
    // Показываем модальное окно с выбором защиты
    final usePassword =
        await showModalBottomSheet<bool>(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder:
              (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Экспорт данных',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Выберите вариант защиты экспортируемых данных:',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 24),
                    ListTile(
                      leading: Icon(Icons.no_encryption, color: Colors.grey),
                      title: Text('Без защиты'),
                      subtitle: Text('Любой сможет импортировать файл без пароля'),
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.enhanced_encryption, color: Colors.green),
                      title: Text('Защита паролем'),
                      subtitle: Text('Для импорта файла потребуется ввести пароль'),
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ),
        ) ??
        false;

    String? password;

    if (usePassword) {
      final pass = await _showPasswordDialog(context);
      if (pass == null) {
        // Пользователь отменил ввод пароля
        return;
      }

      password = pass;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final exportResult = await _monisyncRepo?.exportDataToFile(now: now, password: password);

      if (exportResult != null) {
        final bytes = exportResult.file.readAsBytesSync();

        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Сохранение резервной копии',
          fileName: _monisyncRepo?.getBackupFileName(now),
          bytes: bytes,
        );

        if (result != null) {
          final saveFile = await File(result).writeAsBytes(bytes);

          showToast(
            usePassword ? 'Резервная копия с паролем сохранена' : 'Резервная копия сохранена',
          );

          // Показываем диалог успешного экспорта
          if (usePassword) {
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text('Экспорт завершен'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 48, color: Colors.green),
                        SizedBox(height: 16),
                        Text('Резервная копия успешно сохранена и защищена паролем.'),
                        SizedBox(height: 8),
                        Text(
                          'Не забудьте пароль, иначе вы не сможете восстановить данные!',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('ОК'),
                      ),
                    ],
                  ),
            );
          }
        }
      }
    } on Object catch (error, trace) {
      _log.error('Ошибка экспорта', error: error, trace: trace);
      showToast('Ошибка при экспорте данных');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      final exportResult = await _monisyncRepo?.exportPaymentsToCSV(
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

      // Автоматически определяем, защищен ли файл паролем
      final isPasswordProtected = await _monisyncRepo?.isFilePasswordProtected(filePath);

      String? password;

      if (isPasswordProtected ?? false) {
        // Показываем информационный диалог
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Файл защищен паролем'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 48, color: Colors.amber),
                    SizedBox(height: 16),
                    Text('Выбранный файл защищен паролем. Введите пароль для расшифровки.'),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Понятно'),
                  ),
                ],
              ),
        );

        final pass = await _showPasswordDialog(context, isExport: false);
        if (pass == null) {
          // Пользователь отменил ввод пароля
          return;
        }

        // Конвертируем пароль в ключ через SHA-256
        password = pass;
      }

      try {
        setState(() {
          _isLoading = true;
        });

        // customKey = _passwordToKey('041020');

        await _monisyncRepo?.importDataFromFile(filePath: filePath, password: password);

        showToast('Данные успешно импортированы');
        await _loadPlanners(); // Перезагружаем планеры после импорта
      } catch (e) {
        _log.error('Ошибка импорта', error: e);
        showToast(
          isPasswordProtected ?? false
              ? 'Ошибка импорта: неверный пароль'
              : 'Ошибка при импорте данных',
        );

        // Показываем подробное сообщение об ошибке
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Ошибка импорта'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      isPasswordProtected ?? false
                          ? 'Не удалось расшифровать файл. Проверьте правильность введенного пароля.'
                          : 'Не удалось импортировать данные. Возможно, файл поврежден.',
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text('ОК')),
                ],
              ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
