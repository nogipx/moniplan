// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../entities/license.dart';

/// Сценарий использования для генерации лицензии
class GenerateLicenseUseCase {
  /// Ключ для подписи лицензии
  final String _privateKey;

  /// Конструктор
  const GenerateLicenseUseCase({required String privateKey}) : _privateKey = privateKey;

  /// Генерирует новую лицензию
  License generateLicense({
    required String appId,
    required DateTime expirationDate,
    LicenseType type = LicenseType.trial,
    Map<String, dynamic> features = const {},
    Map<String, dynamic>? metadata,
  }) {
    final id = const Uuid().v4();
    final createdAt = DateTime.now().toUtc();

    // Преобразуем дату истечения в UTC
    final utcExpirationDate = expirationDate.isUtc ? expirationDate : expirationDate.toUtc();

    // Формируем данные для подписи
    final dataToSign = '$id:$appId:${utcExpirationDate.toIso8601String()}:${type.name}';

    // Создаем подпись
    final hmac = Hmac(sha256, utf8.encode(_privateKey));
    final digest = hmac.convert(utf8.encode(dataToSign));
    final signature = digest.toString();

    // Создаем лицензию
    return License(
      id: id,
      appId: appId,
      expirationDate: utcExpirationDate,
      createdAt: createdAt,
      signature: signature,
      type: type,
      features: features,
      metadata: metadata,
    );
  }

  /// Преобразует лицензию в бинарные данные
  Uint8List licenseToBytes(License license, {bool prettyPrint = false}) {
    // Преобразуем в JSON
    final Map<String, dynamic> jsonData = {
      'id': license.id,
      'appId': license.appId,
      'expirationDate': license.expirationDate.toIso8601String(),
      'createdAt': license.createdAt.toIso8601String(),
      'signature': license.signature,
      'type': license.type.name,
      'features': license.features,
      'metadata': license.metadata,
    };

    // Сериализуем в строку JSON
    final jsonString =
        prettyPrint ? JsonEncoder.withIndent('  ').convert(jsonData) : jsonEncode(jsonData);

    // Преобразуем в бинарные данные
    return utf8.encode(jsonString);
  }
}
