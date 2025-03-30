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
  final IAppEncrypter encrypter;
  final AppDb appDb;

  MonisyncRepoImpl({required this.encrypter, required this.appDb});

  @override
  Future<ExportResult?> exportDataToFile({
    required DateTime now,
    String targetFilePath = '',
    String? password,
  }) async {
    final dbFile = await getDatabaseFile();
    final file = File(dbFile.path);

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

      // Если передан пользовательский ключ, создаем соответствующий энкриптер
      if (password != null && password.isNotEmpty) {
        // Используем PasswordMonisyncEncrypter для шифрования с паролем
        final passwordEncrypter = await AppDi.instance.getEncrypter(
          AppEncrypterFactoryArgs(password: password),
        );

        // Шифруем данные
        bytesToWrite = passwordEncrypter.encryptBytes(originalBytes);
      } else {
        // Используем стандартный энкриптер, переданный в конструктор
        bytesToWrite = encrypter.encryptBytes(originalBytes);
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
  Future<bool> isFilePasswordProtected(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final bytes = await file.readAsBytes();

      // Проверяем наличие метаданных
      if (IAppEncrypter.hasMetadata(bytes)) {
        // Извлекаем метаданные и проверяем, защищен ли файл паролем
        final metadata = IAppEncrypter.extractMetadata(bytes);
        return metadata?.hasPassword ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> importDataFromFile({required String filePath, String? password}) async {
    final file = File(filePath);

    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      bool isEncrypted = await isFilePasswordProtected(filePath);

      if (isEncrypted) {
        final encrypter = await AppDi.instance.getEncrypter(
          AppEncrypterFactoryArgs(password: password ?? ''),
        );

        try {
          // Расшифровываем данные
          final decryptedBytes = encrypter.decryptBytes(bytes);

          // Создаем временный файл
          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
            '${tempDir.path}/temp_db_${DateTime.now().millisecondsSinceEpoch}.db',
          );
          await tempFile.writeAsBytes(decryptedBytes);

          // Импортируем из временного файла
          await appDb.overrideDefaultFromFile(newDbFile: tempFile);

          // Удаляем временный файл
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          throw Exception('Не удалось расшифровать файл. Возможно, пароль неверный: $e');
        }
      } else if (isEncrypted && (password == null || password.isEmpty)) {
        throw Exception('Для импорта зашифрованного файла требуется пароль');
      } else {
        // Файл не зашифрован, просто импортируем
        await appDb.overrideDefaultFromFile(newDbFile: file);
      }
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

    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();

    // Проверяем, есть ли у файла метаданные
    if (IAppEncrypter.hasMetadata(bytes)) {
      final metadata = IAppEncrypter.extractMetadata(bytes);
      if (metadata?.isEncrypted == true) {
        // Если файл зашифрован, возвращаем информацию только о файле без содержимого
        return BackupInfo(
          file: File(filePath),
          creationDate: null,
          plannersCount: 0,
          isEncrypted: true,
          hasPassword: metadata?.hasPassword ?? false,
        );
      }
    }

    // Для незашифрованных файлов - стандартная логика
    await appDb.openTemporaryFromFile(dbFile: file);

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
      isEncrypted: false,
      hasPassword: false,
    );
  }
}
