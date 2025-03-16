// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:path_provider/path_provider.dart';

class MonisyncRepoImpl implements IMonisyncRepo {
  final String encryptKey;
  final AppDb appDb;

  MonisyncRepoImpl({required this.appDb, this.encryptKey = ''});

  @override
  Future<ExportResult?> exportDataToFile({
    required DateTime now,
    String targetFilePath = '',
  }) async {
    final file = await getDatabaseFile();

    if (await file.exists()) {
      File exportFile;

      if (targetFilePath.isNotEmpty) {
        exportFile = File(targetFilePath);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        exportFile = File('${directory.path}/${getBackupFileName(now)}');
      }

      final originalBytes = await file.readAsBytes();
      Uint8List bytesToWrite = originalBytes;

      if (encryptKey.isNotEmpty) {
        final encryptionHelper = EncryptionHelper(encryptKey);
        bytesToWrite = encryptionHelper.encryptBytes(originalBytes);
      }

      if (!exportFile.existsSync()) {
        await exportFile.create();
      }

      await exportFile.writeAsBytes(bytesToWrite);

      return ExportResult(file: exportFile);
    }

    return null;
  }

  @override
  Future<ExportResult?> exportPaymentsToCSV({
    required String plannerId,
    bool usePredictedCategories = true,
    String targetFilePath = '',
  }) async {
    // Получаем планер по ID
    final plannerRepo = AppDi.instance.getPlannerRepo();
    final planner = await plannerRepo.getPlannerById(plannerId);

    if (planner == null) {
      return null;
    }

    // Получаем все платежи планера и создаем копию списка, чтобы его можно было сортировать
    final payments = List<Payment>.from(planner.payments);

    // Сортируем платежи по дате (от новых к старым)
    payments.sort((a, b) => b.date.compareTo(a.date));

    // Если нужно использовать предсказанные категории, получаем предиктор из DI
    ICategoryPredictor? predictor;
    if (usePredictedCategories) {
      try {
        print('Получаем предиктор категорий из DI');
        // Получаем предиктор из DI вместо создания нового экземпляра
        predictor = AppDi.instance.getPaymentCategorizer();

        print('Предиктор получен, статус инициализации: ${predictor.isInitialized}');

        // Убеждаемся, что предиктор инициализирован
        if (!predictor.isInitialized) {
          print('Инициализируем предиктор категорий');
          await predictor.initialize();
          print('Предиктор категорий инициализирован');
        }
      } catch (e) {
        print('Ошибка при получении или инициализации предиктора: $e');
        print('Стек ошибки: ${StackTrace.current}');
      }
    }

    // Создаем CSV строки
    final csvRows = <String>[];

    // Добавляем комментарий о формате даты
    csvRows.add('# Экспорт платежей из Moniplan');
    csvRows.add('# Дата экспорта: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    csvRows.add('# Планер: ${planner.name}');
    csvRows.add('# Количество платежей: ${payments.length}');
    csvRows.add('# Примечание: все даты указаны в формате YYYY-MM-DD без учета времени');
    csvRows.add(
      '# Внимание: при создании и редактировании платежей время автоматически отбрасывается',
    );
    csvRows.add('');

    // Добавляем заголовок
    csvRows.add(
      'ID,Дата,Название,Сумма,Валюта,Тип,Категории,Предсказанные категории,Вероятность,Заметка',
    );

    // Форматтер для дат - используем только дату без времени
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Добавляем данные платежей
    for (final payment in payments) {
      final id = payment.paymentId;
      final date = dateFormat.format(payment.date);
      final name = _escapeCSV(payment.details.name);
      final amount = payment.details.money.toString();
      final currency = payment.details.currency.isoCode;
      final type = payment.type.toString().split('.').last;
      final categories =
          payment.details.tags.isEmpty ? '' : _escapeCSV(payment.details.tags.join(', '));
      final note = _escapeCSV(payment.details.note);

      // Предсказанные категории
      String predictedCategories = '';
      String probability = '';

      // Если нужно использовать предсказанные категории и у платежа нет категорий
      if (usePredictedCategories && payment.details.tags.isEmpty && predictor != null) {
        try {
          print('Предсказание категорий для платежа: ${payment.details.name}');
          final predictions = await predictor.predictCategory(payment);
          print('Получены предсказания: ${predictions.length}');

          if (predictions.isNotEmpty) {
            predictedCategories = _escapeCSV(predictions.map((p) => p.category).join(', '));
            probability = predictions.map((p) => p.probability.toStringAsFixed(2)).join(', ');
            print('Предсказанные категории: $predictedCategories');
            print('Вероятности: $probability');
          } else {
            print('Нет предсказаний для платежа: ${payment.details.name}');
          }
        } catch (e) {
          // Игнорируем ошибки предсказания
          print('Ошибка предсказания категории для платежа $id: $e');
          print('Стек ошибки: ${StackTrace.current}');
        }
      }

      // Формируем строку CSV
      final csvRow =
          '$id,$date,$name,$amount,$currency,$type,$categories,$predictedCategories,$probability,$note';
      csvRows.add(csvRow);
    }

    // Создаем CSV контент
    final csvContent = csvRows.join('\n');

    // Создаем файл
    File exportFile;
    if (targetFilePath.isNotEmpty) {
      exportFile = File(targetFilePath);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final fileName = 'payments_${DateFormat('yyyyMMdd').format(now)}.csv';
      exportFile = File('${directory.path}/$fileName');
    }

    // Записываем данные в файл
    if (!exportFile.existsSync()) {
      await exportFile.create();
    }
    await exportFile.writeAsString(csvContent);

    return ExportResult(file: exportFile);
  }

  /// Экранирует специальные символы в CSV
  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      // Заменяем двойные кавычки на две двойные кавычки
      value = value.replaceAll('"', '""');
      // Оборачиваем в кавычки
      return '"$value"';
    }
    return value;
  }

  @override
  Future<void> importDataFromFile({required String filePath}) async {
    final file = File(filePath);

    if (await file.exists()) {
      await appDb.overrideDefaultFromFile(newDbFile: file, encryptKey: mockEncryptionKey);
    }
  }

  @override
  Future<bool> checkNeedSync() {
    throw UnimplementedError();
  }

  @override
  String getBackupFileName(DateTime date) =>
      'db_${DateFormat(backupDateFormat).format(date)}.moniplan';

  @override
  Future<BackupInfo?> readBackupInfo(String filePath) async {
    final cleanedPath = filePath.replaceAll('file://', '');
    final file = File(cleanedPath);

    await appDb.openTemporaryFromFile(dbFile: file, encryptKey: mockEncryptionKey);

    final planners = await AppDi.instance.getPlannerRepo().getPlanners();
    final lastUpdate =
        await appDb.db.managers.globalLastUpdate
            .filter((f) => f.lastUpdateId.equals(GlobalLastUpdate.entityId))
            .getSingleOrNull();

    await appDb.openDefault();

    return BackupInfo(
      file: File(filePath),
      creationDate: lastUpdate?.updatedAt,
      plannersCount: planners.length,
    );
  }
}
