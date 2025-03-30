import 'dart:typed_data';

/// Метаданные зашифрованного бекапа
class BackupMetadata {
  /// Маркер для определения метаданных в файле
  static const metadataMarker = 'MBCKM:';
  static final metadataMarkerBytes = Uint8List.fromList(metadataMarker.codeUnits);
  static const separator = ':';

  /// Флаг, указывающий, зашифрован ли файл
  final bool isEncrypted;

  /// Флаг, указывающий, защищен ли файл паролем
  final bool hasPassword;

  const BackupMetadata({required this.isEncrypted, required this.hasPassword});

  /// Создает метаданные из байтов
  factory BackupMetadata.fromBytes(Uint8List bytes) {
    // Проверяем, есть ли маркер в начале
    if (bytes.length < metadataMarkerBytes.length) {
      return const BackupMetadata(isEncrypted: false, hasPassword: false);
    }

    final markerBytes = bytes.sublist(0, metadataMarkerBytes.length);
    if (!_listEquals(markerBytes, metadataMarkerBytes)) {
      return const BackupMetadata(isEncrypted: false, hasPassword: false);
    }

    // Читаем сами метаданные
    final metadataString = String.fromCharCodes(
      bytes.sublist(
        metadataMarkerBytes.length,
        bytes.indexOf(separator.codeUnitAt(0), metadataMarkerBytes.length),
      ),
    );

    final parts = metadataString.split(',');

    if (parts.length < 2) {
      return const BackupMetadata(isEncrypted: false, hasPassword: false);
    }

    return BackupMetadata(isEncrypted: parts[0] == '1', hasPassword: parts[1] == '1');
  }

  /// Преобразует метаданные в строку
  String toMetadataString() {
    return '${isEncrypted ? '1' : '0'},${hasPassword ? '1' : '0'}';
  }

  /// Преобразует метаданные в байты
  Uint8List toBytes() {
    final metadataString = toMetadataString();
    return Uint8List.fromList([
      ...metadataMarkerBytes,
      ...Uint8List.fromList(metadataString.codeUnits),
      separator.codeUnitAt(0),
    ]);
  }

  /// Добавляет метаданные к байтам
  static Uint8List addMetadataToBytes(
    Uint8List bytes, {
    required bool isEncrypted,
    required bool hasPassword,
  }) {
    final metadata = BackupMetadata(isEncrypted: isEncrypted, hasPassword: hasPassword);
    return Uint8List.fromList([...metadata.toBytes(), ...bytes]);
  }

  /// Извлекает метаданные из байтов и возвращает оригинальные байты
  static (BackupMetadata, Uint8List) extractMetadataFromBytes(Uint8List bytes) {
    // Проверяем наличие маркера метаданных
    if (bytes.length < metadataMarkerBytes.length) {
      return (const BackupMetadata(isEncrypted: false, hasPassword: false), bytes);
    }

    final markerBytes = bytes.sublist(0, metadataMarkerBytes.length);
    if (!_listEquals(markerBytes, metadataMarkerBytes)) {
      return (const BackupMetadata(isEncrypted: false, hasPassword: false), bytes);
    }

    // Ищем конец метаданных (разделитель)
    final separatorIndex = bytes.indexOf(separator.codeUnitAt(0), metadataMarkerBytes.length);

    if (separatorIndex == -1) {
      return (const BackupMetadata(isEncrypted: false, hasPassword: false), bytes);
    }

    final metadata = BackupMetadata.fromBytes(bytes);
    final originalBytes = bytes.sublist(separatorIndex + 1);

    return (metadata, originalBytes);
  }

  /// Вспомогательная функция для сравнения списков байт
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}
