// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:moniplan_domain/src/features/license/domain/entities/license.dart';
import 'test_constants.dart';

/// Вспомогательный класс для создания тестовых лицензий
class TestLicenseFactory {
  /// Создает тестовую лицензию с заданными параметрами
  static License createLicense({
    String id = TestConstants.licenseId,
    String? appId,
    DateTime? expirationDate,
    DateTime? createdAt,
    String? signatureKey,
    LicenseType type = LicenseType.trial,
    Map<String, dynamic> features = const {},
  }) {
    final expDate =
        expirationDate ??
        DateTime.now().add(Duration(days: TestConstants.defaultLicenseDuration)).toUtc();
    final created = createdAt ?? DateTime.now().toUtc();
    final actualAppId = appId ?? TestConstants.appId;
    final actualSignatureKey = signatureKey ?? TestConstants.privateKey;

    // Формируем данные для подписи
    final dataToSign = '$id:$actualAppId:${expDate.toIso8601String()}:${type.name}';

    // Создаем подпись
    final hmac = Hmac(sha256, utf8.encode(actualSignatureKey));
    final digest = hmac.convert(utf8.encode(dataToSign));
    final signature = digest.toString();

    return License(
      id: id,
      appId: actualAppId,
      expirationDate: expDate,
      createdAt: created,
      signature: signature,
      type: type,
      features: features,
    );
  }

  /// Создает истекшую тестовую лицензию
  static License createExpiredLicense({
    String id = TestConstants.licenseId,
    String? appId,
    String? signatureKey,
    LicenseType type = LicenseType.trial,
    Map<String, dynamic> features = const {},
  }) {
    final expDate = DateTime.now().subtract(const Duration(days: 1)).toUtc();
    final created = DateTime.now().subtract(const Duration(days: 31)).toUtc();

    return createLicense(
      id: id,
      appId: appId ?? TestConstants.appId,
      expirationDate: expDate,
      createdAt: created,
      signatureKey: signatureKey ?? TestConstants.privateKey,
      type: type,
      features: features,
    );
  }

  /// Создает лицензию с неверной подписью
  static License createInvalidLicense({
    String id = TestConstants.licenseId,
    String? appId,
    DateTime? expirationDate,
    DateTime? createdAt,
    LicenseType type = LicenseType.trial,
    Map<String, dynamic> features = const {},
  }) {
    final expDate =
        expirationDate ??
        DateTime.now().add(Duration(days: TestConstants.defaultLicenseDuration)).toUtc();
    final created = createdAt ?? DateTime.now().toUtc();
    final actualAppId = appId ?? TestConstants.appId;

    return License(
      id: id,
      appId: actualAppId,
      expirationDate: expDate,
      createdAt: created,
      signature: 'invalid_signature',
      type: type,
      features: features,
    );
  }

  /// Преобразует лицензию в массив байтов для хранения
  static Uint8List licenseToBytes(License license) {
    return license.bytes;
  }
}
