import 'dart:typed_data';

import '_index.dart';

class AppEncrypterFactoryArgs {
  final bool forceOldEncryption;
  final String password;

  const AppEncrypterFactoryArgs({this.forceOldEncryption = false, this.password = ''});
}

/// Интерфейс для шифровальщиков приложения
abstract base class IAppEncrypter {
  /// Ключ шифрования
  final AppEncryptionKey key;

  const IAppEncrypter(this.key);

  /// Определяет, защищён ли бекап паролем
  bool get isPasswordProtected => key is PasswordEncryptionKey && key.rawValue.isNotEmpty;

  /// Шифрует массив байтов
  Uint8List encryptBytes(Uint8List bytes, {Map<String, dynamic>? options});

  /// Расшифровывает массив байтов
  Uint8List decryptBytes(Uint8List bytes, {Map<String, dynamic>? options});

  /// Проверяет, содержит ли файл метаданные
  static bool hasMetadata(Uint8List bytes) {
    if (bytes.length < BackupMetadata.metadataMarkerBytes.length) {
      return false;
    }

    final markerBytes = bytes.sublist(0, BackupMetadata.metadataMarkerBytes.length);
    for (var i = 0; i < BackupMetadata.metadataMarkerBytes.length; i++) {
      if (markerBytes[i] != BackupMetadata.metadataMarkerBytes[i]) {
        return false;
      }
    }

    return true;
  }

  /// Извлекает метаданные из байтов без изменения самих байтов
  static BackupMetadata? extractMetadata(Uint8List bytes) {
    if (!hasMetadata(bytes)) {
      return null;
    }

    return BackupMetadata.fromBytes(bytes);
  }
}
