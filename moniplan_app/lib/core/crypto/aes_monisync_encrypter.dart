// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:moniplan_app/domain/lib/moniplan_domain.dart';

final class AesMonisyncEncrypter extends AppEncrypter {
  final Encrypter _encrypter;

  AesMonisyncEncrypter(super.key, {super.enableMetadata = true})
    : _encrypter = Encrypter(AES(Key.fromBase64(key.base64Value)));

  @override
  Uint8List encryptInternal(Uint8List data, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for AES encryption');
    }
    final aesIv = iv ?? IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(data, iv: aesIv);
    return Uint8List.fromList(aesIv.bytes + encrypted.bytes);
  }

  @override
  Uint8List decryptInternal(Uint8List data, {Map<String, dynamic>? options}) {
    final iv = options?['iv'] as IV?;
    if (options?.containsKey('iv') == true && iv == null) {
      throw ArgumentError('IV is required for AES decryption');
    }

    final aesIv = iv ?? IV(data.sublist(0, 16));
    final encryptedBytes = data.sublist(16);
    return Uint8List.fromList(_encrypter.decryptBytes(Encrypted(encryptedBytes), iv: aesIv));
  }
}
