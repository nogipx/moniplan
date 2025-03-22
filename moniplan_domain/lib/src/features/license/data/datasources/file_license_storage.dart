// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:typed_data';

import 'package:moniplan_domain/moniplan_domain.dart';

/// Реализация хранилища лицензий с использованием файловой системы
class FileLicenseStorage implements ILicenseStorage {
  final IAppDirectoryProvider _directoryProvider;
  final String _licenseFileName;

  /// Конструктор
  const FileLicenseStorage({
    required IAppDirectoryProvider directoryProvider,
    required String licenseFileName,
  }) : _directoryProvider = directoryProvider,
       _licenseFileName = licenseFileName;

  /// Получает путь к файлу лицензии
  Future<String> _getLicenseFilePath() async {
    final appDirPath = await _directoryProvider.getAppDirectoryPath();
    return '$appDirPath/$_licenseFileName';
  }

  @override
  Future<bool> saveLicenseData(Uint8List data) async {
    try {
      final filePath = await _getLicenseFilePath();
      final file = File(filePath);
      await file.writeAsBytes(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Uint8List?> loadLicenseData() async {
    try {
      final filePath = await _getLicenseFilePath();
      final file = File(filePath);

      if (!await file.exists()) {
        return null;
      }

      return await file.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> hasLicense() async {
    try {
      final filePath = await _getLicenseFilePath();
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteLicenseData() async {
    try {
      final filePath = await _getLicenseFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
