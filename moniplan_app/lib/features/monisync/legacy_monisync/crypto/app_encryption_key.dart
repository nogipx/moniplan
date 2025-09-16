import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

abstract base class AppEncryptionKey {
  const AppEncryptionKey();

  abstract final String id;
  abstract final String rawValue;

  String get cleanValue => isBase64 ? utf8.decode(base64Decode(rawValue)) : rawValue;
  String get base64Value => isBase64 ? rawValue : base64Encode(utf8.encode(rawValue));

  bool get isBase64 {
    final str = rawValue;
    if (str.isEmpty) {
      return false;
    }

    // Проверяем, что длина строки кратна 4 (с учетом возможных символов дополнения '=')
    if (str.length % 4 != 0) {
      return false;
    }

    // Проверяем на допустимые символы в Base64
    final regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    if (!regex.hasMatch(str)) {
      return false;
    }

    // Дополнительная проверка через декодирование
    try {
      base64Decode(str);
      return true;
    } on Object catch (_) {
      return false;
    }
  }
}

/// Внутренний класс для представления пароля как ключа шифрования
base class PasswordEncryptionKey extends AppEncryptionKey {
  final Uint8List _passwordDigest;

  PasswordEncryptionKey._(this._passwordDigest);

  factory PasswordEncryptionKey.fromDigest(Uint8List digest) {
    return PasswordEncryptionKey._(digest);
  }

  factory PasswordEncryptionKey.fromHash(String hash) {
    return PasswordEncryptionKey._(base64.decode(hash));
  }

  factory PasswordEncryptionKey.fromPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return PasswordEncryptionKey._(Uint8List.fromList(digest.bytes));
  }

  @override
  String get id => 'password_hashed_encryption_key';

  @override
  String get rawValue => base64.encode(_passwordDigest);

  @override
  String get base64Value => base64.encode(_passwordDigest);

  @override
  String get cleanValue => rawValue;
}
