// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

/// Провайдер информации об устройстве для генерации хеша
///
/// Использует device_info_plus для получения данных о текущем устройстве
class DeviceInfoProvider {
  final DeviceInfoPlugin _deviceInfoPlugin;

  /// Создает провайдер информации об устройстве
  DeviceInfoProvider({DeviceInfoPlugin? deviceInfoPlugin})
    : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  /// Получает информацию об устройстве для генерации хеша
  Future<DeviceInfo> getDeviceInfo() async {
    if (Platform.isAndroid) {
      return _getAndroidDeviceInfo();
    } else if (Platform.isIOS) {
      return _getIosDeviceInfo();
    } else if (Platform.isMacOS) {
      return _getMacOsDeviceInfo();
    } else if (Platform.isWindows) {
      return _getWindowsDeviceInfo();
    } else if (Platform.isLinux) {
      return _getLinuxDeviceInfo();
    } else {
      // Для неизвестных платформ возвращаем базовую информацию
      return DeviceInfo(
        deviceId: DateTime.now().millisecondsSinceEpoch.toString(),
        model: 'Unknown',
        name: 'Unknown Device',
      );
    }
  }

  /// Получает информацию об Android-устройстве
  Future<DeviceInfo> _getAndroidDeviceInfo() async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;

    return DeviceInfo(
      deviceId: androidInfo.id,
      model: androidInfo.model,
      name: androidInfo.device,
      macAddress: null, // Получение MAC-адреса ограничено в Android 6.0+
    );
  }

  /// Получает информацию об iOS-устройстве
  Future<DeviceInfo> _getIosDeviceInfo() async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;

    return DeviceInfo(
      deviceId: iosInfo.identifierForVendor ?? '', // IDFV
      model: iosInfo.model ?? 'Unknown iOS Device',
      name: iosInfo.name ?? 'iOS Device',
      macAddress: null, // Получение MAC-адреса недоступно в iOS
    );
  }

  /// Получает информацию о macOS-устройстве
  Future<DeviceInfo> _getMacOsDeviceInfo() async {
    final macOsInfo = await _deviceInfoPlugin.macOsInfo;

    return DeviceInfo(
      deviceId: macOsInfo.systemGUID ?? macOsInfo.computerName,
      model: macOsInfo.model,
      name: macOsInfo.computerName,
      macAddress: null, // Получение MAC-адреса требует специальных разрешений
    );
  }

  /// Получает информацию о Windows-устройстве
  Future<DeviceInfo> _getWindowsDeviceInfo() async {
    final windowsInfo = await _deviceInfoPlugin.windowsInfo;

    return DeviceInfo(
      deviceId: windowsInfo.deviceId,
      model: windowsInfo.productName,
      name: windowsInfo.computerName,
      macAddress: null,
    );
  }

  /// Получает информацию о Linux-устройстве
  Future<DeviceInfo> _getLinuxDeviceInfo() async {
    final linuxInfo = await _deviceInfoPlugin.linuxInfo;

    return DeviceInfo(
      deviceId: linuxInfo.machineId ?? '',
      model: linuxInfo.prettyName,
      name: linuxInfo.name,
      macAddress: null,
    );
  }
}
