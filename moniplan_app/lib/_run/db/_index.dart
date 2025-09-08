// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

export 'app_db_impl.dart';

typedef IAppDbFactory = IAppDb Function();

abstract class IAppDb {
  Future<void> close();

  Future<void> open();

  Future<void> overwriteWithBytes({required Uint8List bytes});

  Future<String> getPath();
}
