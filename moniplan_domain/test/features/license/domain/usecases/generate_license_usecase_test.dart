// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:test/test.dart';
import 'package:crypto/crypto.dart';

import 'package:moniplan_domain/src/features/license/domain/entities/license.dart';
import 'package:moniplan_domain/src/features/license/domain/usecases/generate_license_usecase.dart';
import '../../helpers/test_constants.dart';

void main() {
  group('GenerateLicenseUseCase', () {
    test('создает_валидную_лицензию_с_заданными_параметрами', () {
      // Arrange
      final sut = GenerateLicenseUseCase(signatureKey: TestConstants.privateKey);
      final expirationDate =
          DateTime.now().add(Duration(days: TestConstants.defaultLicenseDuration)).toUtc();
      final features = {'maxUsers': 10, 'canExport': true};

      // Act
      final license = sut.generateLicense(
        appId: TestConstants.appId,
        expirationDate: expirationDate,
        type: LicenseType.pro,
        features: features,
      );

      // Assert
      expect(license.id, isNotEmpty);
      expect(license.appId, equals(TestConstants.appId));
      expect(license.expirationDate, equals(expirationDate));
      expect(license.type, equals(LicenseType.pro));
      expect(license.features, equals(features));
      expect(license.signature, isNotEmpty);
      expect(license.createdAt.isUtc, isTrue);
    });

    test('правильно_вычисляет_подпись_HMAC', () {
      // Arrange
      final sut = GenerateLicenseUseCase(signatureKey: TestConstants.privateKey);
      final expirationDate =
          DateTime.now().add(Duration(days: TestConstants.defaultLicenseDuration)).toUtc();

      // Act
      final license = sut.generateLicense(
        appId: TestConstants.appId,
        expirationDate: expirationDate,
      );

      // Manually verify the signature
      final dataToVerify =
          '${license.id}:${TestConstants.appId}:${expirationDate.toIso8601String()}:${license.type.name}';
      final hmac = Hmac(sha256, utf8.encode(TestConstants.privateKey));
      final digest = hmac.convert(utf8.encode(dataToVerify));
      final expectedSignature = digest.toString();

      // Assert
      expect(license.signature, equals(expectedSignature));
    });

    test('по_умолчанию_создает_пробную_лицензию', () {
      // Arrange
      final sut = GenerateLicenseUseCase(signatureKey: TestConstants.privateKey);

      // Act
      final license = sut.generateLicense(
        appId: TestConstants.appId,
        expirationDate: DateTime.now().add(Duration(days: TestConstants.defaultLicenseDuration)),
      );

      // Assert
      expect(license.type, equals(LicenseType.trial));
    });

    test('сериализует_лицензию_в_JSON_байты', () {
      // Arrange
      final sut = GenerateLicenseUseCase(signatureKey: TestConstants.privateKey);
      final license = sut.generateLicense(
        appId: TestConstants.appId,
        expirationDate: DateTime.now().add(Duration(days: TestConstants.defaultLicenseDuration)),
        type: LicenseType.standard,
        features: {'maxUsers': 5},
      );

      // Act
      final bytes = sut.licenseToBytes(license);

      // Assert
      final jsonString = utf8.decode(bytes);
      final jsonData = jsonDecode(jsonString);

      expect(jsonData['id'], equals(license.id));
      expect(jsonData['appId'], equals(license.appId));
      expect(jsonData['signature'], equals(license.signature));
      expect(jsonData['type'], equals(license.type.name));
      expect(jsonData['features']['maxUsers'], equals(5));
    });

    test('форматирует_JSON_с_отступами_при_необходимости', () {
      // Arrange
      final sut = GenerateLicenseUseCase(signatureKey: TestConstants.privateKey);
      final license = sut.generateLicense(
        appId: TestConstants.appId,
        expirationDate: DateTime.now().add(Duration(days: TestConstants.defaultLicenseDuration)),
      );

      // Act
      final bytes = sut.licenseToBytes(license, prettyPrint: true);
      final jsonString = utf8.decode(bytes);

      // Assert
      // Проверяем форматирование JSON (наличие отступов и переносов строк)
      expect(jsonString, contains('\n'));
      expect(jsonString, contains('  "'));
    });
  });
}
