// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monisync/keys.dart';
import 'package:moniplan_app/features/payment/repo/payment_planner_repo_drift.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:path_provider/path_provider.dart';

class MonisyncRepoImpl implements IMonisyncRepo {
  final IAppEncrypter encrypter;
  final AppDb appDb;
  final _log = AppLog('MonisyncRepoImpl');

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

      // Используем PasswordMonisyncEncrypter для шифрования с паролем
      final encrypter = await AppDi.instance.getEncrypter(
        AppEncrypterFactoryArgs(
          password: password ?? '',
          preferNewEncryption: true,
          enableMetadata: true,
        ),
      );

      // Шифруем данные с автоматическим добавлением метаданных
      bytesToWrite = encrypter.encryptBytes(originalBytes);

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
        _log.debug('Получаем предиктор категорий из DI');
        // Получаем предиктор из DI вместо создания нового экземпляра
        predictor = AppDi.instance.getPaymentCategorizer();

        _log.debug('Предиктор получен, статус инициализации: ${predictor.isInitialized}');

        // Убеждаемся, что предиктор инициализирован
        if (!predictor.isInitialized) {
          _log.debug('Инициализируем предиктор категорий');
          await predictor.initialize();
          _log.debug('Предиктор категорий инициализирован');
        }
      } catch (e, trace) {
        _log.error('Ошибка при получении или инициализации предиктора: $e', trace: trace);
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
          _log.debug('Предсказание категорий для платежа: ${payment.details.name}');
          final predictions = await predictor.predictCategory(payment);
          _log.debug('Получены предсказания: ${predictions.length}');

          if (predictions.isNotEmpty) {
            predictedCategories = _escapeCSV(predictions.map((p) => p.category).join(', '));
            probability = predictions.map((p) => p.probability.toStringAsFixed(2)).join(', ');
            _log.debug('Предсказанные категории: $predictedCategories');
            _log.debug('Вероятности: $probability');
          } else {
            _log.debug('Нет предсказаний для платежа: ${payment.details.name}');
          }
        } catch (e, trace) {
          // Игнорируем ошибки предсказания
          _log.error('Ошибка предсказания категории для платежа $id: $e', trace: trace);
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
  Future<void> importDataFromFile({required String filePath, String? password = '041020'}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Файл не найден');
    }

    final bytes = await file.readAsBytes();
    final (_, originalBytes) = BackupMetadata.extractMetadataFromBytes(bytes);

    final decryptedBytes = await _tryDecrypt(originalBytes, password: password);
    if (decryptedBytes == null) {
      throw Exception('Не удалось расшифровать файл');
    }

    // Импортируем из временного файла
    await appDb.overwriteWithBytes(bytes: decryptedBytes);
  }

  @override
  Future<BackupInfo?> readBackupInfo({
    required String filePath,
    String? password = '041020',
  }) async {
    final cleanedPath = filePath.replaceAll('file://', '');
    final file = File(cleanedPath);

    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    final (metadata, originalBytes) = BackupMetadata.extractMetadataFromBytes(bytes);
    Uint8List? effectiveBytes = originalBytes;

    // Пытаемся расшифровать файл
    effectiveBytes = await _tryDecrypt(originalBytes, password: password);

    // Если расшифровать не удалось, но есть метаданные - возвращаем базовую информацию
    if (effectiveBytes == null) {
      return BackupInfo(
        file: File(filePath),
        creationDate: null,
        plannersCount: 0,
        backupMetadata: metadata,
        isLegacyBackup: false,
        additionalInfo:
            metadata.isEncrypted == true
                ? {'key_type': metadata.hasPassword ? 'password' : 'app_key', 'format': 'metadata'}
                : {'error': 'Не удалось расшифровать файл'},
      );
    }

    await AppDb.instance.close();
    await driftWriteTemporary(bytes: effectiveBytes);

    final tempDb = AppDb.detachedInMemory();
    await tempDb.open();
    final plannerRepo = PlannerRepoDrift(appDb: tempDb);

    final planners = await plannerRepo.getPlanners();
    final lastUpdate =
        await tempDb.db.managers.globalLastUpdate
            .filter((f) => f.lastUpdateId.equals('1'))
            .getSingleOrNull();
    await tempDb.close();

    await AppDb.instance.open();

    return BackupInfo(
      file: File(filePath),
      creationDate: lastUpdate?.updatedAt,
      plannersCount: planners.length,
      isLegacyBackup: false,
      backupMetadata: metadata,
    );
  }

  Future<Uint8List?> _tryDecrypt(Uint8List bytes, {String? password}) async {
    return _tryDecryptWithKeys(
      bytes,
      LinkedHashMap.from({
        OldMockedEncryptionKey(): (key) => AesMonisyncEncrypter(key, enableMetadata: true),
        OldEnviedEncryptionKey(): (key) => AesMonisyncEncrypter(key, enableMetadata: true),
        MonisyncEncryptionKeyV2(): (key) => Salsa20MonisyncEncrypter(key, enableMetadata: true),
        if (password != null)
          PasswordEncryptionKey.fromPassword(password):
              (key) => Salsa20MonisyncEncrypter(key, enableMetadata: true),
      }),
    );
  }

  Future<Uint8List?> _tryDecryptWithKeys(
    Uint8List bytes,
    Map<AppEncryptionKey, IAppEncrypter Function(AppEncryptionKey)> keyToEncrypter,
  ) async {
    for (final key in keyToEncrypter.keys) {
      try {
        final encrypter = keyToEncrypter[key]!(key);
        final decryptedBytes = encrypter.decryptBytes(bytes);
        return decryptedBytes;
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  @override
  Future<bool> checkNeedSync() {
    throw UnimplementedError();
  }

  @override
  String getBackupFileName(DateTime date) =>
      'db_${DateFormat(backupDateFormat).format(date)}.moniplan';
}
