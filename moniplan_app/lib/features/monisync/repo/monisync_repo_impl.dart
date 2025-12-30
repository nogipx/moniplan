import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:licensify/licensify.dart';
import 'package:moniplan_app/features/monisync/models/backup_footer_metadata.dart';
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
  Future<String> exportData({
    required DateTime now,
    required String password,
  }) async {
    final dbBytes = await _exportDatabaseBytes(dataService);
    final compressed = _gzipEncode(dbBytes);

    // Создаем метаданные для footer
    final metadata = BackupFooterMetadata(timestamp: now);

    // Создаем ключ шифрования
    final encryptionKey = getLicensifyPasswordKey(password);
    try {
      // Шифруем содержимое базы данных с метаданными в footer
      return await Licensify.encryptData(
        data: {
          'content': base64Encode(compressed),
          'compression': 'gzip',
        },
        encryptionKey: encryptionKey,
        footer: metadata.toFooter(),
      );
    } on Object catch (e, s) {
      _log.error(
        'Ошибка при чтении информации о бэкапе',
        error: e,
        stackTrace: s,
      );
      rethrow;
    } finally {
      encryptionKey.dispose();
    }
  }

  @override
  Future<void> importData({
    required String token,
    required String password,
  }) async {
    if (!token.startsWith('v4.local.')) {
      throw Exception('Неверный формат данных');
    }

    final encryptionKey = getLicensifyPasswordKey(password);
    try {
      final decryptedData = await Licensify.decryptData(
        encryptedToken: token,
        encryptionKey: encryptionKey,
      );

      final bytes = _decodeDatabaseBytes(decryptedData);
      await _importDatabaseBytes(dataService, bytes);
    } on Object catch (e, s) {
      _log.error(
        'Ошибка при чтении информации о бэкапе',
        error: e,
        stackTrace: s,
      );
      rethrow;
    } finally {
      encryptionKey.dispose();
    }
  }

  @override
  Future<BackupInfo?> readBackupInfo({
    required String token,
    String? password,
  }) async {
    if (!token.startsWith('v4.local.')) {
      return null;
    }

    final metadata = BackupFooterMetadata.fromFooter(_extractFooter(token));
    if (password == null) {
      return BackupInfo(
        token: token,
        creationDate: metadata?.timestamp,
        metadata: metadata,
      );
    }

    final encryptionKey = getLicensifyPasswordKey(password);
    try {
      final decryptedData = await Licensify.decryptData(
        encryptedToken: token,
        encryptionKey: encryptionKey,
      );

      final bytes = _decodeDatabaseBytes(decryptedData);

      final tempEnv = await DataServiceFactory.inMemory();
      try {
        await _importDatabaseBytes(tempEnv.client, bytes);

        return BackupInfo(
          token: token,
          creationDate: metadata?.timestamp,
          metadata: metadata,
        );
      } finally {
        await tempEnv.dispose();
      }
    } on Object catch (e, s) {
      _log.error(
        'Ошибка при чтении информации о бэкапе',
        error: e,
        stackTrace: s,
      );
      rethrow;
    } finally {
      encryptionKey.dispose();
    }
  }

  Uint8List _decodeDatabaseBytes(Map<String, dynamic> decryptedData) {
    final content = decryptedData['content'] as String;
    final compression = decryptedData['compression'] as String?;
    final encodedBytes = base64Decode(content);

    final bytes = Uint8List.fromList(encodedBytes);
    if (compression == 'gzip') {
      final decoded = _gzipDecode(bytes);
      if (decoded != null) {
        return decoded;
      }
    }

    return bytes;
  }

  Uint8List _gzipEncode(Uint8List data) {
    try {
      final encoded = const GZipEncoder().encode(data);
      if (encoded.isNotEmpty) {
        return Uint8List.fromList(encoded);
      }
    } on Object catch (_) {
      // Fallback to uncompressed on encode errors.
    }
    return data;
  }

  Uint8List? _gzipDecode(Uint8List compressed) {
    try {
      final decoded = const GZipDecoder().decodeBytes(compressed, verify: false);
      return Uint8List.fromList(decoded);
    } on Object catch (_) {
      return null;
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

  @override
  String createBackupFileName(DateTime date) =>
      'db_${DateFormat(backupDateFormat).format(date)}.moniplan';

  Future<void> _importDatabaseBytes(
    IDataService target,
    Uint8List bytes,
  ) async {
    final payload = utf8.decode(bytes);
    await target.importDatabase(payload: payload, replaceExisting: true);
  }

  Future<Uint8List> _exportDatabaseBytes(IDataService target) async {
    final payload = await _readExportPayload(target);
    return Uint8List.fromList(utf8.encode(payload));
  }

  Future<String> _readExportPayload(IDataService target) async {
    final export = await target.exportDatabase(includePayloadString: false);
    final stream = export.payloadStream;
    if (stream != null) {
      final buffer = StringBuffer();
      await for (final chunk in stream.transform(utf8.decoder)) {
        buffer.write(chunk);
      }
      return buffer.toString();
    }
    return export.payload;
  }
}
