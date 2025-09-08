// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/domain/lib/moniplan_domain.dart';
import 'package:moniplan_app/features/monisync/models/backup_footer_metadata.dart';
import 'package:moniplan_app/features/payment/repo/payment_planner_repo_drift.dart';
import 'package:rpc_dart/logger.dart';

import '../models/backup_info.dart';
import 'i_manual_monisync_repo.dart';

// Формат даты для файла бэкапа
const String backupDateFormat = 'yyyyMMdd_HHmmss';

class MonisyncRepoImpl implements IMonisyncRepo {
  final AppDb appDb;
  final _log = RpcLogger('MonisyncRepoImpl');

  MonisyncRepoImpl({required this.appDb});

  @override
  Future<String> exportData({required DateTime now, String? password}) async {
    final dbBytes = await getDatabaseBytes();

    // Создаем метаданные для footer
    final metadata = BackupFooterMetadata(
      timestamp: now,
      protectionType:
          password != null ? BackupProtectionType.password : BackupProtectionType.defaultKey,
    );

    // Создаем ключ шифрования
    final encryptionKey = Licensify.generateEncryptionKey();
    try {
      // Шифруем содержимое базы данных с метаданными в footer
      return await Licensify.encryptData(
        data: {'content': base64Encode(dbBytes)},
        encryptionKey: encryptionKey,
        footer: metadata.toFooter(),
      );
    } finally {
      encryptionKey.dispose();
    }
  }

  @override
  Future<void> importData({required String token, String? password}) async {
    if (!token.startsWith('v4.local.')) {
      throw Exception('Неверный формат данных');
    }

    final metadata = BackupFooterMetadata.fromFooter(_extractFooter(token));

    if (metadata?.protectionType == BackupProtectionType.password && password == null) {
      throw Exception('Данные защищены паролем');
    }

    final encryptionKey = Licensify.generateEncryptionKey();
    try {
      final decryptedData = await Licensify.decryptData(
        encryptedToken: token,
        encryptionKey: encryptionKey,
      );

      final content = decryptedData['content'] as String;
      await appDb.overwriteWithBytes(bytes: base64Decode(content));
    } finally {
      encryptionKey.dispose();
    }
  }

  @override
  Future<BackupInfo?> readBackupInfo({required String token, String? password}) async {
    if (!token.startsWith('v4.local.')) {
      return null;
    }

    final metadata = BackupFooterMetadata.fromFooter(_extractFooter(token));

    if (metadata?.protectionType == BackupProtectionType.password && password == null) {
      return BackupInfo(
        token: token,
        creationDate: metadata?.timestamp,
        plannersCount: 0,
        metadata: metadata,
      );
    }

    final encryptionKey = Licensify.generateEncryptionKey();
    try {
      final decryptedData = await Licensify.decryptData(
        encryptedToken: token,
        encryptionKey: encryptionKey,
      );

      final content = decryptedData['content'] as String;
      final bytes = base64Decode(content);

      await AppDb.instance.close();
      final tempDb = AppDb.detachedInMemory();
      await tempDb.open();
      await tempDb.overwriteWithBytes(bytes: bytes);

      final plannerRepo = PlannerRepoDrift(appDb: tempDb);
      final planners = await plannerRepo.getPlanners();

      await tempDb.close();
      await AppDb.instance.open();

      return BackupInfo(
        token: token,
        creationDate: metadata?.timestamp,
        plannersCount: planners.length,
        metadata: metadata,
      );
    } finally {
      encryptionKey.dispose();
    }
  }

  /// Извлекает footer из PASETO токена
  String? _extractFooter(String token) {
    try {
      final parts = token.split('.');
      if (parts.length >= 4) {
        return utf8.decode(base64Url.decode(parts.last));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Получает байты базы данных
  Future<Uint8List> getDatabaseBytes() async {
    final path = await appDb.getPath();
    final bytes = await File(path).readAsBytes();
    return bytes;
  }

  @override
  String createBackupFileName(DateTime date) =>
      'db_${DateFormat(backupDateFormat).format(date)}.moniplan';
}
