// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:path_provider/path_provider.dart';

class MonisyncRepoImpl implements IMonisyncRepo {
  final String encryptKey;
  final AppDb appDb;

  MonisyncRepoImpl({
    required this.appDb,
    this.encryptKey = '',
  });

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
      await appDb.overrideDefaultFromFile(
        newDbFile: file,
        encryptKey: mockEncryptionKey,
      );
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

    await appDb.openTemporaryFromFile(
      dbFile: file,
      encryptKey: mockEncryptionKey,
    );

    final planners = await AppDi.instance.getPlannerRepo().getPlanners();
    final lastUpdate = await appDb.db.managers.globalLastUpdate
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
