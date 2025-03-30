// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

abstract interface class IMonisyncEncrypter {
  Uint8List encryptBytes(Uint8List bytes, {Map<String, dynamic>? options});

  Uint8List decryptBytes(Uint8List bytes, {Map<String, dynamic>? options});
}
