import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:moniplan/_run/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

import 'package:path_provider/path_provider.dart';

String generateEncryptionKey() {
  final random = Random.secure();
  final values = List<int>.generate(32, (i) => random.nextInt(256));
  return base64Url.encode(values);
}

class MonisyncRepoImpl implements IMonisyncRepo {
  final String encryptKey;

  MonisyncRepoImpl({this.encryptKey = ''});

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

      return ExportResult(
        file: exportFile,
      );
    }

    return null;
  }

  @override
  Future<void> importDataFromFile({required String filePath}) async {
    final file = File(filePath);

    if (await file.exists()) {
      await AppDb().overrideDefaultFromFile(file);
    }
  }

  @override
  Future<bool> checkNeedSync() {
    // TODO: implement checkNeedSync
    throw UnimplementedError();
  }

  @override
  String getBackupFileName(DateTime date) =>
      'db_${DateFormat(backupDateFormat).format(date)}.moniplan';

  @override
  Future<BackupInfo?> readBackupInfo(String filePath) async {
    final cleanedPath = filePath.replaceAll('file://', '');
    final file = File(cleanedPath);

    await AppDb().openFromFile(file);

    final planners = await PlannerRepoDrift(db: AppDb()).getPlanners();
    final lastUpdate = await AppDb()
        .db
        .managers
        .globalLastUpdate
        .filter((f) => f.lastUpdateId.equals(GlobalLastUpdate.entityId))
        .getSingleOrNull();

    await AppDb().openDefault();

    return BackupInfo(
      file: File(filePath),
      creationDate: lastUpdate?.updatedAt,
      plannersCount: planners.length,
    );
  }
}
