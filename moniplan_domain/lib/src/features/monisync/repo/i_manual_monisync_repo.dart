import 'dart:io';

class ExportResult {
  final File file;

  ExportResult({required this.file});
}

abstract interface class IMonisyncRepo {
  String getBackupFileName(DateTime date);

  Future<void> importDataFromFile({
    required String filePath,
  });

  Future<ExportResult?> exportDataToFile({
    String targetFilePath = '',
  });

  Future<bool> checkNeedSync();
}
