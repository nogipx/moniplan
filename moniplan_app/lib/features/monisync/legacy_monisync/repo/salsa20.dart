import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

import '../crypto/_index.dart';

final class Salsa20MonisyncEncrypter extends AppEncrypter {
  final Encrypter _encrypter;

  Salsa20MonisyncEncrypter(super.key, {super.enableMetadata = true})
    : _encrypter = Encrypter(Salsa20(Key.fromBase64(key.base64Value)));

  @override
  Uint8List encryptInternal(Uint8List data, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for Salsa20 encryption');
    }

    final salsa20Iv = iv ?? IV.fromLength(8);
    final encrypted = _encrypter.encryptBytes(data, iv: salsa20Iv);
    return Uint8List.fromList(salsa20Iv.bytes + encrypted.bytes);
  }

  @override
  Uint8List decryptInternal(Uint8List data, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for Salsa20 decryption');
    }

    final salsa20Iv = iv ?? IV(data.sublist(0, 8));
    final encryptedBytes = data.sublist(8);
    return Uint8List.fromList(_encrypter.decryptBytes(Encrypted(encryptedBytes), iv: salsa20Iv));
  }
}
