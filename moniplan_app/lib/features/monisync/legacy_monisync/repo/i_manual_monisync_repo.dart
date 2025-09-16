import 'dart:io';

import '../crypto/app_encryption_key.dart';
import '../crypto/backup_metadata.dart';

class ExportResult {
  final File file;

  ExportResult({required this.file});
}

class LegacyBackupInfo {
  final File file;
  final DateTime? creationDate;
  final int plannersCount;
  final bool isLegacyBackup;
  final BackupMetadata? backupMetadata;
  final AppEncryptionKey? encryptionKey;

  /// Дополнительная информация о бекапе, которая может отличаться в зависимости от типа
  final Map<String, dynamic>? additionalInfo;

  LegacyBackupInfo({
    required this.file,
    required this.creationDate,
    required this.plannersCount,
    this.isLegacyBackup = false,
    this.additionalInfo,
    this.backupMetadata,
    this.encryptionKey,
  });
}

abstract interface class LegacyIMonisyncRepo {
  Future<void> importDataFromFile({required String filePath, String? password});

  /// Проверяет, защищен ли файл паролем
  Future<bool> isFilePasswordProtected(String filePath);

  Future<LegacyBackupInfo?> readBackupInfo({required String filePath, String? password});
}
