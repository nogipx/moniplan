// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_app/core/config/env.dart';

/// Сервис для генерации лицензий
class LicenseGeneratorService {
  final GenerateLicenseUseCase _generator;

  LicenseGeneratorService()
    : _generator = GenerateLicenseUseCase(
        privateKey: utf8.decode(base64Decode(SecureEnv.privateKey ?? '')),
      );

  /// Генерирует лицензию с указанными параметрами и возвращает байты лицензии
  Future<License> generateLicense({
    required String appId,
    required DateTime expirationDate,
    LicenseType? type,
    Map<String, dynamic>? features,
    Map<String, dynamic>? metadata,
  }) async {
    final license = _generator.generateLicense(
      appId: appId,
      expirationDate: expirationDate,
      type: type ?? LicenseType.pro,
      features: features ?? {},
      metadata: metadata ?? {},
    );

    final validator = LicenseValidator(publicKey: utf8.decode(base64Decode(SecureEnv.publicKey)));
    final validatorUseCase = LicenseValidateUseCase(
      validator: validator,
      schema: moniplanLicenseSchema,
    );
    final result = await validatorUseCase(license);
    if (!result.isActive) {
      throw result;
    }
    return license;
  }
}
