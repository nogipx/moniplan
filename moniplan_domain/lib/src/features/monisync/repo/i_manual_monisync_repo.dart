import 'dart:io';

class ExportResult {
  final File file;

  ExportResult({required this.file});
}

class BackupInfo {
  final File file;
  final DateTime? creationDate;
  final int plannersCount;

  BackupInfo({
    required this.file,
    required this.creationDate,
    required this.plannersCount,
  });
}

abstract interface class IMonisyncRepo {
  String getBackupFileName(DateTime date);

  Future<void> importDataFromFile({
    required String filePath,
  });

  Future<ExportResult?> exportDataToFile({
    required DateTime now,
    String targetFilePath = '',
  });

  Future<bool> checkNeedSync();

  Future<BackupInfo?> readBackupInfo(String filePath);
}
