// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:licensify/licensify.dart';

/// Определяет ключи функций, которые могут быть ограничены лицензией
enum LicenseFeatureKey {
  maxPlanners, // Максимальное количество планеров
  maxForecastMonths, // Максимальный период прогнозирования в месяцах
  maxCategories, // Максимальное количество категорий
  maxDevices, // Максимальное количество устройств
  enableSync, // Включение синхронизации
  enableAdvancedAnalytics, // Включение продвинутой аналитики
  enableExport, // Включение экспорта данных
  enableAiPredictions, // Включение ИИ-предсказаний
  enableAutoCategories, // Включение автоматической категоризации
}

/// Класс для определения набора функций, доступных в лицензии
class LicenseFeatureSet {
  final License? _license;
  final LicenseType _defaultType;

  /// Функции лицензии по умолчанию для типа Trial
  static const Map<String, dynamic> _trialFeatures = {
    'maxPlanners': 1,
    'maxForecastMonths': 1,
    'maxCategories': 5,
    'maxDevices': 1,
    'enableSync': false,
    'enableAdvancedAnalytics': false,
    'enableExport': false,
    'enableAiPredictions': false,
    'enableAutoCategories': false,
  };

  /// Функции лицензии по умолчанию для типа Standard
  static const Map<String, dynamic> _standardFeatures = {
    'maxPlanners': 3,
    'maxForecastMonths': 3,
    'maxCategories': 15,
    'maxDevices': 2,
    'enableSync': true,
    'enableAdvancedAnalytics': false,
    'enableExport': true,
    'enableAiPredictions': false,
    'enableAutoCategories': false,
  };

  /// Функции лицензии по умолчанию для типа Pro
  static const Map<String, dynamic> _proFeatures = {
    'maxPlanners': -1, // Неограниченно
    'maxForecastMonths': -1, // Неограниченно
    'maxCategories': -1, // Неограниченно
    'maxDevices': -1, // Неограниченно
    'enableSync': true,
    'enableAdvancedAnalytics': true,
    'enableExport': true,
    'enableAiPredictions': true,
    'enableAutoCategories': true,
  };

  /// Конструктор
  LicenseFeatureSet(this._license, [this._defaultType = LicenseType.trial]);

  /// Получает значение функции из лицензии, или значение по умолчанию для типа лицензии
  T getFeatureValue<T>(LicenseFeatureKey key, {T? defaultValue}) {
    if (_license == null) {
      return defaultValue ?? _getDefaultValue<T>(key, _defaultType);
    }

    final keyStr = key.toString().split('.').last;

    // Проверяем, есть ли в лицензии переопределение функции
    if (_license.features.containsKey(keyStr)) {
      final value = _license.features[keyStr];
      if (value is T) {
        return value;
      }
    }

    // Возвращаем значение по умолчанию для типа лицензии
    return _getDefaultValue<T>(key, _license.type);
  }

  /// Получает значение функции по умолчанию для указанного типа лицензии
  static T getDefaultValueForType<T>(LicenseFeatureKey key, LicenseType type) {
    final keyStr = key.toString().split('.').last;
    Map<String, dynamic> defaultFeatures;

    switch (type) {
      case LicenseType.trial:
        defaultFeatures = _trialFeatures;
        break;
      case LicenseType.standard:
        defaultFeatures = _standardFeatures;
        break;
      case LicenseType.pro:
        defaultFeatures = _proFeatures;
        break;
      default:
        defaultFeatures = _trialFeatures;
    }

    if (defaultFeatures.containsKey(keyStr)) {
      final value = defaultFeatures[keyStr];
      if (value is T) {
        return value;
      }
    }

    throw ArgumentError('Неизвестная функция лицензии или несовместимый тип: $key');
  }

  /// Получает значение функции по умолчанию для указанного типа лицензии
  T _getDefaultValue<T>(LicenseFeatureKey key, LicenseType type) {
    return getDefaultValueForType<T>(key, type);
  }

  /// Проверяет, имеет ли лицензия доступ к определенной функции
  bool hasFeature(LicenseFeatureKey key) {
    switch (key) {
      case LicenseFeatureKey.enableSync:
      case LicenseFeatureKey.enableAdvancedAnalytics:
      case LicenseFeatureKey.enableExport:
      case LicenseFeatureKey.enableAiPredictions:
      case LicenseFeatureKey.enableAutoCategories:
        return getFeatureValue<bool>(key);
      case LicenseFeatureKey.maxPlanners:
      case LicenseFeatureKey.maxForecastMonths:
      case LicenseFeatureKey.maxCategories:
      case LicenseFeatureKey.maxDevices:
        return getFeatureValue<int>(key) != 0; // 0 означает отключено, -1 неограниченно
    }
  }

  /// Проверяет, не превышено ли ограничение на количественную функцию
  bool isWithinLimit(LicenseFeatureKey key, int currentValue) {
    if (key == LicenseFeatureKey.maxPlanners ||
        key == LicenseFeatureKey.maxForecastMonths ||
        key == LicenseFeatureKey.maxCategories ||
        key == LicenseFeatureKey.maxDevices) {
      final limit = getFeatureValue<int>(key);
      // -1 означает безлимитно
      return limit == -1 || currentValue <= limit;
    }
    throw ArgumentError('Неприменимая функция для проверки лимита: $key');
  }
}
