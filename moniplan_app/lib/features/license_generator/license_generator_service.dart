// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:typed_data';

import 'package:licensify/licensify.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Сервис для генерации лицензий
class LicenseGeneratorService {
  final GenerateLicenseUseCase _generator;

  LicenseGeneratorService() : _generator = GenerateLicenseUseCase(privateKey: 'privateKey');

  /// Генерирует лицензию с указанными параметрами и возвращает байты лицензии
  License generateLicense({
    required String appId,
    required DateTime expirationDate,
    LicenseType? type,
    Map<String, dynamic>? features,
    Map<String, dynamic>? metadata,
  }) {
    return _generator.generateLicense(
      appId: appId,
      expirationDate: expirationDate,
      type: type ?? LicenseType.pro,
      features: features ?? {},
      metadata: metadata ?? {},
    );
  }

  /// Генерирует лицензию и делится ею через системный диалог
  Future<void> generateAndShareLicense({
    required String appId,
    required DateTime expirationDate,
    LicenseType? type,
    Map<String, dynamic>? features,
    Map<String, dynamic>? metadata,
    String? fileName,
  }) async {
    final license = generateLicense(
      appId: appId,
      expirationDate: expirationDate,
      type: type,
      features: features,
      metadata: metadata,
    );

    final fileBytes = license.bytes;
    final name = fileName ?? 'license_${appId}_${DateTime.now().millisecondsSinceEpoch}.lic';

    await _shareLicenseFile(fileBytes, name);
  }

  /// Делится лицензией через системный диалог
  Future<void> _shareLicenseFile(Uint8List licenseBytes, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(licenseBytes);

      await Share.shareXFiles([XFile(file.path, name: fileName)]);
    } catch (e) {
      // Логирование ошибки
      print('Ошибка при сохранении/отправке лицензии: $e');
      rethrow;
    }
  }
}
