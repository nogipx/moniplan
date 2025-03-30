// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

class ExportResult {
  final File file;

  ExportResult({required this.file});
}

class BackupInfo {
  final File file;
  final DateTime? creationDate;
  final int plannersCount;

  BackupInfo({required this.file, required this.creationDate, required this.plannersCount});
}

abstract interface class IMonisyncRepo {
  String getBackupFileName(DateTime date);

  Future<void> importDataFromFile({required String filePath, String? password});

  Future<ExportResult?> exportDataToFile({
    required DateTime now,
    String targetFilePath = '',
    String? password,
  });

  /// Проверяет, защищен ли файл паролем
  Future<bool> isFilePasswordProtected(String filePath);

  /// Экспортирует данные платежей в CSV файл с предсказанными категориями
  ///
  /// [plannerId] - ID планера, данные которого нужно экспортировать
  /// [usePredictedCategories] - использовать ли предсказанные категории для платежей без категорий
  /// [targetFilePath] - путь к файлу для сохранения (если пустой, будет сгенерирован автоматически)
  ///
  /// Возвращает результат экспорта с информацией о созданном файле
  Future<ExportResult?> exportPaymentsToCSV({
    required String plannerId,
    bool usePredictedCategories = true,
    String targetFilePath = '',
  });

  Future<bool> checkNeedSync();

  Future<BackupInfo?> readBackupInfo(String filePath);
}
