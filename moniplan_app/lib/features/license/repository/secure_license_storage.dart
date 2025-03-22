// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

/// Реализация хранилища лицензий с использованием SharedPreferences
class SecureLicenseStorage implements ILicenseStorage {
  final FlutterSecureStorage _secure;
  static const _licenseKey = 'moniplan_license_data';

  SecureLicenseStorage(this._secure);

  @override
  Future<bool> deleteLicenseData() async {
    await _secure.delete(key: _licenseKey);
    return true;
  }

  @override
  Future<bool> hasLicense() async {
    return await _secure.containsKey(key: _licenseKey);
  }

  @override
  Future<Uint8List?> loadLicenseData() async {
    final licenseBase64 = await _secure.read(key: _licenseKey);
    if (licenseBase64 == null || licenseBase64.isEmpty) {
      return null;
    }

    try {
      final bytes = base64Decode(licenseBase64);
      return Uint8List.fromList(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveLicenseData(Uint8List data) async {
    final licenseBase64 = base64Encode(data);
    await _secure.write(key: _licenseKey, value: licenseBase64);
    return true;
  }
}
