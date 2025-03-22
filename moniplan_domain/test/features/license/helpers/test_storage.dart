// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:moniplan_domain/src/features/license/domain/repositories/license_storage.dart';

/// Реализация хранилища лицензий в памяти для тестирования
class InMemoryLicenseStorage implements ILicenseStorage {
  Uint8List? _data;
  bool _hasData = false;

  @override
  Future<bool> deleteLicenseData() async {
    _data = null;
    _hasData = false;
    return true;
  }

  @override
  Future<bool> hasLicense() async {
    return _hasData;
  }

  @override
  Future<Uint8List?> loadLicenseData() async {
    return _data;
  }

  @override
  Future<bool> saveLicenseData(Uint8List data) async {
    _data = data;
    _hasData = true;
    return true;
  }

  /// Симуляция ошибки в хранилище
  void simulateError({bool canSave = true, bool canLoad = true, bool canDelete = true}) {
    if (!canSave) {
      _data = null;
      _hasData = false;
    }
  }
}
