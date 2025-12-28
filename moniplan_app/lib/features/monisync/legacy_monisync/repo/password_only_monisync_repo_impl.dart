import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:rpc_dart_data/rpc_dart_data.dart';

import '../crypto/_index.dart';
import 'i_manual_monisync_repo.dart';
import 'salsa20.dart';

// Формат даты для файла бэкапа
const String backupDateFormat = 'yyyyMMdd_HHmmss';

/// Реализация legacy репозитория, которая работает ТОЛЬКО с паролями пользователя
/// Исключает поддержку стандартного ключа приложения для повышения безопасности
class PasswordOnlyLegacyMonisyncRepoImpl implements LegacyIMonisyncRepo {
  final IDataService dataService;

  PasswordOnlyLegacyMonisyncRepoImpl({required this.dataService});

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

      // Если нет метаданных, считаем что файл требует пароль
      // (для совместимости со старыми версиями)
      return true;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<void> importDataFromFile({required String filePath, String? password}) async {
    if (password == null) {
      throw Exception('Пароль обязателен для импорта legacy файлов');
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Файл не найден');
    }

    final bytes = await file.readAsBytes();
    final (metadata, originalBytes) = BackupMetadata.extractMetadataFromBytes(bytes);

    // Проверяем, что файл защищен паролем
    if (metadata.isEncrypted && !metadata.hasPassword) {
      throw Exception(
        'Файл зашифрован стандартным ключом приложения. Поддерживаются только файлы с пользовательским паролем.',
      );
    }

    final decryptedBytes = await _tryDecryptWithPasswordOnly(originalBytes, password: password);
    if (decryptedBytes == null) {
      throw Exception('Не удалось расшифровать файл. Проверьте правильность пароля.');
    }

    // Импортируем из временного файла
    await _importDatabaseBytes(decryptedBytes);
  }

  @override
  Future<LegacyBackupInfo?> readBackupInfo({required String filePath, String? password}) async {
    if (password == null) {
      return LegacyBackupInfo(
        file: File(filePath),
        creationDate: null,
        plannersCount: 0,
        additionalInfo: {
          'error': 'Пароль обязателен для чтения legacy файлов',
          'requires_password': true,
        },
      );
    }

    final cleanedPath = filePath.replaceAll('file://', '');
    final file = File(cleanedPath);

    if (!file.existsSync()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    final (metadata, originalBytes) = BackupMetadata.extractMetadataFromBytes(bytes);

    // Проверяем, что файл защищен паролем
    if (metadata.isEncrypted && !metadata.hasPassword) {
      return LegacyBackupInfo(
        file: File(filePath),
        creationDate: null,
        plannersCount: 0,
        backupMetadata: metadata,
        additionalInfo: {
          'error':
              'Файл зашифрован стандартным ключом приложения. Поддерживаются только файлы с пользовательским паролем.',
          'key_type': 'app_key_not_supported',
          'format': 'metadata',
        },
      );
    }

    final effectiveBytes = await _tryDecryptWithPasswordOnly(originalBytes, password: password);

    // Если расшифровать не удалось, возвращаем информацию об ошибке
    if (effectiveBytes == null) {
      return LegacyBackupInfo(
        file: File(filePath),
        creationDate: null,
        plannersCount: 0,
        backupMetadata: metadata,
        additionalInfo: {
          'error': 'Не удалось расшифровать файл. Проверьте правильность пароля.',
          'key_type': 'password',
          'format': 'metadata',
        },
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

  /// Пытается расшифровать данные ТОЛЬКО с использованием пароля пользователя
  /// Исключает попытки с стандартным ключом приложения
  Future<Uint8List?> _tryDecryptWithPasswordOnly(
    Uint8List bytes, {
    required String password,
  }) async {
    try {
      final passwordKey = PasswordEncryptionKey.fromPassword(password);
      final encrypter = Salsa20MonisyncEncrypter(passwordKey);
      final decryptedBytes = encrypter.decryptBytes(bytes);

      if (isSQLiteBytes(decryptedBytes)) {
        return decryptedBytes;
      }
    } on Object catch (e) {
      print(e);
      // Игнорируем ошибки расшифровки
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

  Future<void> _importDatabaseBytes(Uint8List bytes) async {
    final payload = utf8.decode(bytes);
    await dataService.importDatabase(payload: payload, replaceExisting: true);
  }
}
