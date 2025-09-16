import 'dart:typed_data';

import '_index.dart';

/// Базовая реализация шифровальщика приложения, управляющая метаданными
/// Наследники должны реализовать методы _encryptInternal и _decryptInternal
abstract base class AppEncrypter extends IAppEncrypter {
  /// Флаг, определяющий, нужно ли автоматически добавлять/извлекать метаданные
  final bool enableMetadata;

  const AppEncrypter(super.key, {this.enableMetadata = true});

  @override
  Uint8List encryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    // Сначала шифруем данные через внутренний метод, который должны реализовать наследники
    final encrypted = encryptInternal(bytes, options: options);

    // Добавляем метаданные, если нужно
    final bool addMetadata = options?['addMetadata'] ?? enableMetadata;
    if (addMetadata) {
      return BackupMetadata.addMetadataToBytes(
        encrypted,
        isEncrypted: true,
        hasPassword: isPasswordProtected,
      );
    }

    return encrypted;
  }

  @override
  Uint8List decryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    // Сначала проверяем наличие метаданных
    var result = bytes;

    // Проверяем наличие метаданных в байтах
    if (IAppEncrypter.hasMetadata(result)) {
      final (metadata, originalBytes) = BackupMetadata.extractMetadataFromBytes(result);

      // Нужно ли сохранять метаданные в options
      final bool extractMetadata = options?['extractMetadata'] ?? enableMetadata;
      if (extractMetadata && options != null) {
        options['metadata'] = metadata;
      }

      // В любом случае отрезаем метаданные, если они есть
      result = originalBytes;
    }

    // Затем расшифровываем сами данные через внутренний метод
    return decryptInternal(result, options: options);
  }

  /// Выполняет шифрование данных (должен быть реализован наследниками)
  Uint8List encryptInternal(Uint8List data, {Map<String, dynamic>? options});

  /// Выполняет расшифровку данных (должен быть реализован наследниками)
  Uint8List decryptInternal(Uint8List data, {Map<String, dynamic>? options});
}
