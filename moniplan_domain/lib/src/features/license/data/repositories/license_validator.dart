// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../domain/entities/license.dart';
import '../../domain/repositories/license_validator.dart';

/// Реализация валидатора лицензии
class LicenseValidator implements ILicenseValidator {
  /// Ключ для проверки подписи
  final String _publicKey;

  /// Конструктор
  const LicenseValidator({required String publicKey}) : _publicKey = publicKey;

  @override
  bool validateSignature(License license) {
    try {
      // Формируем данные для проверки подписи
      final dataToVerify =
          '${license.id}:${license.appId}:${license.expirationDate.toIso8601String()}:${license.type.name}';

      // Создаем подпись
      final hmac = Hmac(sha256, utf8.encode(_publicKey));
      final digest = hmac.convert(utf8.encode(dataToVerify));
      final calculatedSignature = digest.toString();

      // Сравниваем с подписью в лицензии
      return calculatedSignature == license.signature;
    } catch (e) {
      return false;
    }
  }

  @override
  bool validateExpiration(License license) {
    // Лицензия действительна, если дата истечения еще не наступила
    return !license.isExpired;
  }

  @override
  bool validateLicense(License license) {
    // Лицензия валидна, если подпись верна и срок действия не истек
    return validateSignature(license) && validateExpiration(license);
  }
}
