// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

import '_interface.dart';

final class Salsa20MonisyncEncrypter implements IMonisyncEncrypter {
  final Encrypter _encrypter;

  Salsa20MonisyncEncrypter({required Encrypter encrypter}) : _encrypter = encrypter;

  @override
  Uint8List encryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for Salsa20 encryption');
    }

    final salsa20Iv = iv ?? IV.fromLength(8);
    return _encrypter.encryptBytes(bytes, iv: salsa20Iv).bytes;
  }

  @override
  Uint8List decryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for Salsa20 decryption');
    }

    final salsa20Iv = iv ?? IV.fromLength(8);
    return Uint8List.fromList(_encrypter.decryptBytes(Encrypted(bytes), iv: salsa20Iv));
  }
}
