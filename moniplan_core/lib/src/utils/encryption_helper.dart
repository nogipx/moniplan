import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  final Encrypter _encrypter;

  EncryptionHelper(String keyBase64) : _encrypter = Encrypter(AES(Key.fromBase64(keyBase64)));

  Uint8List encryptFile({
    required File dbFile,
    required String key,
  }) {
    if (key.isNotEmpty) {
      return encryptBytes(dbFile.readAsBytesSync());
    }
    throw Exception('Encryption key is empty');
  }

  Uint8List decryptFile({
    required File dbFile,
    required String key,
  }) {
    if (key.isNotEmpty) {
      return decryptBytes(dbFile.readAsBytesSync());
    }
    throw Exception('Encryption key is empty');
  }

  Uint8List encryptBytes(Uint8List bytes) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(bytes, iv: iv);
    final encryptedWithIv = Uint8List.fromList(iv.bytes + encrypted.bytes);
    return encryptedWithIv;
  }

  Uint8List decryptBytes(Uint8List bytes) {
    final iv = IV(bytes.sublist(0, 16));
    final encryptedBytes = bytes.sublist(16);
    final decrypted = _encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
    return Uint8List.fromList(decrypted);
  }
}
