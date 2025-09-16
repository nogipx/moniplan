import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:moniplan_app/database/drift/app_db.dart';

import '../crypto/_index.dart';
import '../crypto/keys.dart';
import 'i_manual_monisync_repo.dart';
import 'salsa20.dart';

// Формат даты для файла бэкапа
const String backupDateFormat = 'yyyyMMdd_HHmmss';

class LegacyMonisyncRepoImpl implements LegacyIMonisyncRepo {
  final IAppEncrypter encrypter;
  final AppDb appDb;

  LegacyMonisyncRepoImpl({required this.encrypter, required this.appDb});

  @override
  Future<bool> isFilePasswordProtected(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return false;
      }

      final bytes = await file.readAsBytes();

      // Проверяем наличие метаданных
      if (IAppEncrypter.hasMetadata(bytes)) {
        // Извлекаем метаданные и проверяем, защищен ли файл паролем
        final metadata = IAppEncrypter.extractMetadata(bytes);
        return metadata?.hasPassword ?? false;
      }

      return false;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<void> importDataFromFile({required String filePath, String? password}) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Файл не найден');
    }

    final bytes = await file.readAsBytes();
    final (_, originalBytes) = BackupMetadata.extractMetadataFromBytes(bytes);

    final decryptedBytes = await _tryDecrypt(originalBytes, password: password);
    if (decryptedBytes == null) {
      throw Exception('Не удалось расшифровать файл');
    }

    // Импортируем из временного файла
    await appDb.overwriteWithBytes(bytes: decryptedBytes);
  }

  @override
  Future<LegacyBackupInfo?> readBackupInfo({required String filePath, String? password}) async {
    final cleanedPath = filePath.replaceAll('file://', '');
    final file = File(cleanedPath);

    if (!file.existsSync()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    final (metadata, originalBytes) = BackupMetadata.extractMetadataFromBytes(bytes);
    Uint8List? effectiveBytes = originalBytes;

    // Пытаемся расшифровать файл
    effectiveBytes = await _tryDecrypt(originalBytes, password: password);

    // Если расшифровать не удалось, но есть метаданные - возвращаем базовую информацию
    if (effectiveBytes == null) {
      return LegacyBackupInfo(
        file: File(filePath),
        creationDate: null,
        plannersCount: 0,
        backupMetadata: metadata,
        additionalInfo:
            metadata.isEncrypted == true
                ? {'key_type': metadata.hasPassword ? 'password' : 'app_key', 'format': 'metadata'}
                : {'error': 'Не удалось расшифровать файл'},
      );
    }

    return LegacyBackupInfo(
      file: File(filePath),
      creationDate: DateTime(0),
      plannersCount: 0,
      isLegacyBackup: true,
      backupMetadata: metadata,
    );
  }

  Future<Uint8List?> _tryDecrypt(Uint8List bytes, {String? password}) async {
    return _tryDecryptWithKeys(
      bytes,
      LinkedHashMap.from({
        MonisyncEncryptionKeyV2(): (key) => Salsa20MonisyncEncrypter(key),
        if (password != null)
          PasswordEncryptionKey.fromPassword(password): (key) => Salsa20MonisyncEncrypter(key),
      }),
    );
  }

  Future<Uint8List?> _tryDecryptWithKeys(
    Uint8List bytes,
    Map<AppEncryptionKey, IAppEncrypter Function(AppEncryptionKey)> keyToEncrypter,
  ) async {
    for (final key in keyToEncrypter.keys) {
      try {
        final encrypter = keyToEncrypter[key]!(key);
        final decryptedBytes = encrypter.decryptBytes(bytes);

        if (isSQLiteBytes(decryptedBytes)) {
          return decryptedBytes;
        }
        continue;
      } on Object catch (_) {
        continue;
      }
    }

    return null;
  }

  /// Проверяет, соответствуют ли байты сигнатуре SQLite базы данных
  /// SQLite файлы начинаются с сигнатуры "SQLite format 3\0"
  bool isSQLiteBytes(Uint8List bytes) {
    if (bytes.length < 16) {
      return false;
    }

    // Сигнатура SQLite: "SQLite format 3\0"
    final signature = [
      0x53,
      0x51,
      0x4C,
      0x69,
      0x74,
      0x65,
      0x20,
      0x66,
      0x6F,
      0x72,
      0x6D,
      0x61,
      0x74,
      0x20,
      0x33,
      0x00,
    ];

    for (var i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) {
        return false;
      }
    }

    return true;
  }
}
