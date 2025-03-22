// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:test/test.dart';

import 'package:moniplan_domain/src/features/license/domain/entities/license.dart';
import 'package:moniplan_domain/src/features/license/data/repositories/license_validator.dart';
import '../../helpers/test_factory.dart';
import '../../helpers/test_constants.dart';

void main() {
  group('LicenseValidator', () {
    test('подтверждает_корректную_подпись_лицензии', () {
      // Arrange
      final sut = LicenseValidator(publicKey: TestConstants.publicKey);
      final license = TestLicenseFactory.createLicense(
        signatureKey: TestConstants.publicKey,
        appId: TestConstants.appId,
      );

      // Act
      final result = sut.validateSignature(license);

      // Assert
      expect(result, isTrue);
    });

    test('отклоняет_лицензию_с_неверной_подписью', () {
      // Arrange
      final sut = LicenseValidator(publicKey: TestConstants.publicKey);
      final license = TestLicenseFactory.createInvalidLicense(appId: TestConstants.appId);

      // Act
      final result = sut.validateSignature(license);

      // Assert
      expect(result, isFalse);
    });

    test('отклоняет_лицензию_с_неправильным_ключом', () {
      // Arrange
      final license = TestLicenseFactory.createLicense(
        signatureKey: 'different_key',
        appId: TestConstants.appId,
      );
      final sut = LicenseValidator(publicKey: TestConstants.publicKey);

      // Act
      final result = sut.validateSignature(license);

      // Assert
      expect(result, isFalse);
    });

    test('подтверждает_действие_непросроченной_лицензии', () {
      // Arrange
      final sut = LicenseValidator(publicKey: TestConstants.publicKey);
      final license = TestLicenseFactory.createLicense(
        expirationDate:
            DateTime.now().add(Duration(days: TestConstants.defaultLicenseDuration)).toUtc(),
      );

      // Act
      final result = sut.validateExpiration(license);

      // Assert
      expect(result, isTrue);
    });

    test('отклоняет_просроченную_лицензию', () {
      // Arrange
      final sut = LicenseValidator(publicKey: TestConstants.publicKey);
      final license = TestLicenseFactory.createExpiredLicense();

      // Act
      final result = sut.validateExpiration(license);

      // Assert
      expect(result, isFalse);
    });

    test('подтверждает_полностью_валидную_лицензию', () {
      // Arrange
      final sut = LicenseValidator(publicKey: TestConstants.publicKey);
      final license = TestLicenseFactory.createLicense(
        signatureKey: TestConstants.publicKey,
        appId: TestConstants.appId,
      );

      // Act
      final result = sut.validateLicense(license);

      // Assert
      expect(result, isTrue);
    });

    test('отклоняет_лицензию_с_валидной_подписью_но_просроченную', () {
      // Arrange
      final sut = LicenseValidator(publicKey: TestConstants.publicKey);
      final license = TestLicenseFactory.createExpiredLicense(
        signatureKey: TestConstants.publicKey,
        appId: TestConstants.appId,
      );

      // Act
      final result = sut.validateLicense(license);

      // Assert
      expect(result, isFalse);
    });

    test('отклоняет_лицензию_с_неверной_подписью_но_действующим_сроком', () {
      // Arrange
      final sut = LicenseValidator(publicKey: TestConstants.publicKey);
      final license = TestLicenseFactory.createInvalidLicense(appId: TestConstants.appId);

      // Act
      final result = sut.validateLicense(license);

      // Assert
      expect(result, isFalse);
    });
  });
}
