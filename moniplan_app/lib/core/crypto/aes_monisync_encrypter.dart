// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

final class AesMonisyncEncrypter extends IAppEncrypter {
  final Encrypter _encrypter;

  AesMonisyncEncrypter(super.key, {super.enableEncryptionMarker})
    : _encrypter = Encrypter(AES(Key.fromBase64(key.base64Value)));

  @override
  Uint8List encryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for AES encryption');
    }
    final aesIv = iv ?? IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(bytes, iv: aesIv);
    final encryptedWithIv = Uint8List.fromList(aesIv.bytes + encrypted.bytes);
    return super.encryptBytes(encryptedWithIv);
  }

  @override
  Uint8List decryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for AES decryption');
    }
    final effectiveBytes = super.decryptBytes(bytes);

    final aesIv = iv ?? IV(effectiveBytes.sublist(0, 16));
    final encryptedBytes = effectiveBytes.sublist(16);
    final decrypted = _encrypter.decryptBytes(Encrypted(encryptedBytes), iv: aesIv);
    return Uint8List.fromList(decrypted);
  }
}
