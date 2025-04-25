// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:licensify/licensify.dart';

/// Модель данных устройства, используемых для генерации хеша
class DeviceInfo {
  /// Идентификатор устройства (Android ID для Android, IDFV для iOS)
  final String deviceId;

  /// Модель устройства
  final String model;

  /// Имя устройства
  final String name;

  /// MAC-адрес (если доступен)
  final String? macAddress;

  /// Создает экземпляр информации об устройстве
  DeviceInfo({required this.deviceId, required this.model, required this.name, this.macAddress});

  /// Преобразует данные устройства в строку для хеширования
  String toHashString() {
    final baseString = '${deviceId}_${model}_$name';
    return macAddress != null ? '${baseString}_$macAddress' : baseString;
  }
}

IDeviceHashGenerator getDeviceHashGenerator(DeviceInfo deviceInfo) => () async {
  final dataToHash = deviceInfo.toHashString();

  // Используем SHA-512 для хеширования данных устройства
  final bytes = utf8.encode(dataToHash);
  final digest = sha512.convert(bytes);

  return digest.toString();
};
