// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:moniplan_app/features/monisync/encrypters/_interface.dart';

class AesMonisyncEncrypter implements IMonisyncEncrypter {
  final Encrypter _encrypter;

  AesMonisyncEncrypter(String keyBase64) : _encrypter = Encrypter(AES(Key.fromBase64(keyBase64)));

  @override
  Uint8List encryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for AES encryption');
    }
    final aesIv = iv ?? IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(bytes, iv: aesIv);
    final encryptedWithIv = Uint8List.fromList(aesIv.bytes + encrypted.bytes);
    return encryptedWithIv;
  }

  @override
  Uint8List decryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for AES decryption');
    }
    final aesIv = iv ?? IV(bytes.sublist(0, 16));
    final encryptedBytes = bytes.sublist(16);
    final decrypted = _encrypter.decryptBytes(Encrypted(encryptedBytes), iv: aesIv);
    return Uint8List.fromList(decrypted);
  }
}
