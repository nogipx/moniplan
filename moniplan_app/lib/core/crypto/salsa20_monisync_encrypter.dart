// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

final class Salsa20MonisyncEncrypter extends IAppEncrypter {
  final Encrypter _encrypter;

  Salsa20MonisyncEncrypter(super.key, {super.enableEncryptionMarker = true})
    : _encrypter = Encrypter(Salsa20(Key.fromBase64(key.base64Value)));

  @override
  Uint8List encryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for Salsa20 encryption');
    }

    final salsa20Iv = iv ?? IV.fromLength(8);
    final encrypted = _encrypter.encryptBytes(bytes, iv: salsa20Iv);
    final encryptedWithIv = Uint8List.fromList(salsa20Iv.bytes + encrypted.bytes);
    return super.encryptBytes(encryptedWithIv);
  }

  @override
  Uint8List decryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for Salsa20 decryption');
    }

    final effectiveBytes = super.decryptBytes(bytes);
    final salsa20Iv = iv ?? IV.fromLength(8);
    return Uint8List.fromList(_encrypter.decryptBytes(Encrypted(effectiveBytes), iv: salsa20Iv));
  }
}
