class ExportResult {
  final String filePath;

  ExportResult({required this.filePath});
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
