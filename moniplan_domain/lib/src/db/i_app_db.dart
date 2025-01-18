// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

typedef IAppDbFactory = IAppDb Function();

abstract class IAppDb {
  Future<void> close();

  Future<void> openDefault();

  Future<void> overrideDefaultFromFile({
    required File newDbFile,
    String encryptKey = '',
  });

  Future<void> openTemporaryFromFile({
    required File dbFile,
    String encryptKey = '',
  });
}
