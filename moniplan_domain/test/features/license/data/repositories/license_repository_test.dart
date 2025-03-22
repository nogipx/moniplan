// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';

import 'package:moniplan_domain/src/features/license/data/repositories/license_repository.dart';
import 'package:moniplan_domain/src/features/license/domain/entities/license.dart';
import '../../helpers/test_factory.dart';
import '../../helpers/test_storage.dart';

void main() {
  group('LicenseRepository', () {
    late InMemoryLicenseStorage storage;
    late LicenseRepository sut;

    setUp(() {
      storage = InMemoryLicenseStorage();
      sut = LicenseRepository(storage: storage);
    });

    test('возвращает_null_если_лицензия_отсутствует', () async {
      // Arrange - хранилище пустое по умолчанию

      // Act
      final result = await sut.getCurrentLicense();

      // Assert
      expect(result, isNull);
    });

    test('загружает_валидную_лицензию_из_хранилища', () async {
      // Arrange
      final license = TestLicenseFactory.createLicense();
      final licenseData = TestLicenseFactory.licenseToBytes(license);

      // Сохраняем лицензию в хранилище
      await storage.saveLicenseData(licenseData);

      // Act
      final result = await sut.getCurrentLicense();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(license.id));
      expect(result.appId, equals(license.appId));
      expect(result.type, equals(license.type));
    });

    test('возвращает_null_при_повреждении_данных', () async {
      // Arrange - сохраняем невалидные данные
      await storage.saveLicenseData(
        TestLicenseFactory.licenseToBytes(TestLicenseFactory.createLicense()),
      );
      // Портим данные
      await storage.saveLicenseData(Uint8List.fromList('invalid json'.codeUnits));

      // Act
      final result = await sut.getCurrentLicense();

      // Assert
      expect(result, isNull);
    });

    test('успешно_сохраняет_лицензию', () async {
      // Arrange
      final license = TestLicenseFactory.createLicense();

      // Act
      final result = await sut.saveLicense(license);

      // Assert
      expect(result, isTrue);

      // Дополнительно проверяем, что лицензия действительно сохранена
      final savedLicense = await sut.getCurrentLicense();
      expect(savedLicense, isNotNull);
      expect(savedLicense!.id, equals(license.id));
    });

    test('сохраняет_лицензию_из_массива_байтов', () async {
      // Arrange
      final license = TestLicenseFactory.createLicense();
      final licenseData = TestLicenseFactory.licenseToBytes(license);

      // Act
      final result = await sut.saveLicenseFromBytes(licenseData);

      // Assert
      expect(result, isTrue);

      // Дополнительно проверяем, что лицензия действительно сохранена
      final savedLicense = await sut.getCurrentLicense();
      expect(savedLicense, isNotNull);
      expect(savedLicense!.id, equals(license.id));
    });

    test('сохраняет_лицензию_из_существующего_файла', () async {
      // Arrange - создаем временный файл для теста
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_license.dat');

      // Создаем лицензию и записываем ее в файл
      final license = TestLicenseFactory.createLicense();
      final licenseData = TestLicenseFactory.licenseToBytes(license);
      await tempFile.writeAsBytes(licenseData);

      // Act
      final result = await sut.saveLicenseFromFile(tempFile.path);

      // Assert
      expect(result, isTrue);

      // Дополнительно проверяем, что лицензия действительно сохранена
      final savedLicense = await sut.getCurrentLicense();
      expect(savedLicense, isNotNull);
      expect(savedLicense!.id, equals(license.id));

      // Cleanup
      await tempFile.delete();
    });

    test('возвращает_ошибку_при_отсутствии_файла', () async {
      // Arrange
      const nonExistentPath = '/path/that/does/not/exist.lic';

      // Act
      final result = await sut.saveLicenseFromFile(nonExistentPath);

      // Assert
      expect(result, isFalse);
    });

    test('успешно_удаляет_существующую_лицензию', () async {
      // Arrange - сохраняем лицензию, чтобы было что удалять
      final license = TestLicenseFactory.createLicense();
      await sut.saveLicense(license);

      // Act
      final result = await sut.removeLicense();

      // Assert
      expect(result, isTrue);

      // Дополнительно проверяем, что лицензия действительно удалена
      final savedLicense = await sut.getCurrentLicense();
      expect(savedLicense, isNull);
    });
  });
}
