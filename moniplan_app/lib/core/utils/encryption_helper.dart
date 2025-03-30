// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  final Encrypter _encrypter;

  EncryptionHelper({required Encrypter encrypter}) : _encrypter = encrypter;

  Uint8List encryptFile({required File dbFile, IV? iv}) {
    return encryptBytes(dbFile.readAsBytesSync(), iv: iv);
  }

  Uint8List decryptFile({required File dbFile, IV? iv}) {
    return decryptBytes(dbFile.readAsBytesSync(), iv: iv);
  }

  Uint8List encryptBytes(Uint8List bytes, {IV? iv}) {
    // Для Salsa20 нужен IV длиной 8 байт
    final salsa20Iv = iv ?? IV.fromLength(8);
    return _encrypter.encryptBytes(bytes, iv: salsa20Iv).bytes;
  }

  Uint8List decryptBytes(Uint8List bytes, {IV? iv}) {
    // Для Salsa20 нужен IV длиной 8 байт
    final salsa20Iv = iv ?? IV.fromLength(8);
    return Uint8List.fromList(_encrypter.decryptBytes(Encrypted(bytes), iv: salsa20Iv));
  }
}
