import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:licensify/licensify.dart';
import 'package:moniplan_app/features/monisync/models/backup_footer_metadata.dart';
import 'package:moniplan_app/features/payment/repo/payment_planner_repo_data_service.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

import '../models/backup_info.dart';
import 'i_manual_monisync_repo.dart';

// Формат даты для файла бэкапа
const String backupDateFormat = 'yyyyMMdd_HHmmss';

class MonisyncRepoImpl implements IMonisyncRepo {
  final IDataService dataService;
  final _log = RpcLogger('MonisyncRepoImpl');

  MonisyncRepoImpl({required this.dataService});

  @override
  Future<String> exportData({required DateTime now, required String password}) async {
    final dbBytes = await getDatabaseBytes();

    // Создаем метаданные для footer
    final metadata = BackupFooterMetadata(timestamp: now);

    // Создаем ключ шифрования
    final encryptionKey = getLicensifyPasswordKey(password);
    try {
      // Шифруем содержимое базы данных с метаданными в footer
      return await Licensify.encryptData(
        data: {'content': base64Encode(dbBytes)},
        encryptionKey: encryptionKey,
        footer: metadata.toFooter(),
      );
    } on Object catch (e, s) {
      _log.error('Ошибка при чтении информации о бэкапе', error: e, stackTrace: s);
      rethrow;
    } finally {
      encryptionKey.dispose();
    }
  }

  @override
  Future<void> importData({required String token, required String password}) async {
    if (!token.startsWith('v4.local.')) {
      throw Exception('Неверный формат данных');
    }

    final encryptionKey = getLicensifyPasswordKey(password);
    try {
      final decryptedData = await Licensify.decryptData(
        encryptedToken: token,
        encryptionKey: encryptionKey,
      );

      final content = decryptedData['content'] as String;
      await _importDatabaseBytes(dataService, base64Decode(content));
    } on Object catch (e, s) {
      _log.error('Ошибка при чтении информации о бэкапе', error: e, stackTrace: s);
      rethrow;
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
    if (password == null) {
      return BackupInfo(
        token: token,
        creationDate: metadata?.timestamp,
        metadata: metadata,
        plannersCount: 0,
      );
    }

    final encryptionKey = getLicensifyPasswordKey(password);
    try {
      final decryptedData = await Licensify.decryptData(
        encryptedToken: token,
        encryptionKey: encryptionKey,
      );

      final content = decryptedData['content'] as String;
      final bytes = base64Decode(content);

      final tempEnv = await DataServiceFactory.inMemory();
      try {
        await _importDatabaseBytes(tempEnv.client, bytes);

        final plannerRepo = PlannerRepoDataService(dataService: tempEnv.client);
        final planners = await plannerRepo.getPlanners();

        return BackupInfo(
          token: token,
          creationDate: metadata?.timestamp,
          plannersCount: planners.length,
          metadata: metadata,
        );
      } finally {
        await tempEnv.dispose();
      }
    } on Object catch (e, s) {
      _log.error('Ошибка при чтении информации о бэкапе', error: e, stackTrace: s);
      rethrow;
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
    } on Object catch (_) {
      return null;
    }
  }

  /// Получает байты базы данных
  Future<Uint8List> getDatabaseBytes() async {
    return _exportDatabaseBytes(dataService);
  }

  @override
  String createBackupFileName(DateTime date) =>
      'db_${DateFormat(backupDateFormat).format(date)}.moniplan';

  Future<void> _importDatabaseBytes(IDataService target, Uint8List bytes) async {
    final payload = utf8.decode(bytes);
    await target.importDatabase(payload: payload, replaceExisting: true);
  }

  Future<Uint8List> _exportDatabaseBytes(IDataService target) async {
    final export = await target.exportDatabase();
    return Uint8List.fromList(utf8.encode(export.payload));
  }
}
