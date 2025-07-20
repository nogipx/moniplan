import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:licensify/licensify.dart';

abstract interface class IAppEncryptionKey {
  String get id;
  LicensifySymmetricKey get licensifyKey;
}

/// Внутренний класс для представления пароля как ключа шифрования
base class PasswordEncryptionKey extends IAppEncryptionKey {
  final Uint8List _passwordDigest;

  PasswordEncryptionKey._(this._passwordDigest);

  factory PasswordEncryptionKey.fromDigest(Uint8List digest) {
    return PasswordEncryptionKey._(digest);
  }

  factory PasswordEncryptionKey.fromBase64(String hash) {
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
  LicensifySymmetricKey get licensifyKey =>
      LicensifySymmetricKey.xchacha20(_passwordDigest);
}
