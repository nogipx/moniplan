// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:licensify/licensify.dart';
import 'package:moniplan_domain/src/features/license/features/license_feature_set.dart';
import 'package:moniplan_domain/src/features/license/i_moniplan_license_repository.dart';

/// Сервис для управления функциями, доступными на основе текущей лицензии
class LicenseFeaturesService {
  final IMoniplanLicenseRepo _licenseRepo;
  License? _cachedLicense;
  LicenseFeatureSet? _featureSet;
  bool _isLicenseValid = false;
  bool _isLicenseExpired = false;

  /// Конструктор
  LicenseFeaturesService(this._licenseRepo);

  /// Инициализирует сервис, загружая текущую лицензию
  Future<void> initialize() async {
    await _refreshLicense();
  }

  /// Обновляет кэшированную лицензию
  Future<void> _refreshLicense() async {
    final license = await _licenseRepo.getCurrentLicense();
    final status = await _licenseRepo.getLicenseStatus(license: license);

    // Сбрасываем состояния
    _isLicenseValid = false;
    _isLicenseExpired = false;

    if (license != null) {
      _cachedLicense = license;

      // Проверяем статус лицензии
      if (status.isActive) {
        _isLicenseValid = true;
      } else if (license.isExpired) {
        _isLicenseExpired = true;
      }

      // Если лицензия невалидная или просроченная, но это Pro-лицензия,
      // используем Standard тип для ограничений
      if ((!_isLicenseValid || _isLicenseExpired) && license.type == LicenseType.pro) {
        // Создаем временную лицензию Standard типа для ограничений функций
        _featureSet = LicenseFeatureSet(null, LicenseType.standard);
      } else {
        // Используем настоящую лицензию
        _featureSet = LicenseFeatureSet(_cachedLicense);
      }
    } else {
      _cachedLicense = null;
      // Без лицензии - используем ограничения Standard
      _featureSet = LicenseFeatureSet(null, LicenseType.standard);
    }
  }

  /// Проверяет доступность функции в текущей лицензии
  Future<bool> hasFeature(LicenseFeatureKey key) async {
    await _ensureInitialized();

    // Если это продвинутые функции, доступные только в Pro,
    // и лицензия не валидна или не Pro - запрещаем
    if (_isProOnlyFeature(key) && (!_isLicenseValid || _cachedLicense?.type != LicenseType.pro)) {
      return false;
    }

    return _featureSet!.hasFeature(key);
  }

  /// Проверяет, является ли функция доступной только в Pro-версии
  bool _isProOnlyFeature(LicenseFeatureKey key) {
    // Эти функции доступны только в Pro-версии
    const proOnlyFeatures = [
      LicenseFeatureKey.enableAdvancedAnalytics,
      LicenseFeatureKey.enableAiPredictions,
      LicenseFeatureKey.enableAutoCategories,
    ];

    return proOnlyFeatures.contains(key);
  }

  /// Получает значение конкретной функции лицензии
  Future<T> getFeatureValue<T>(LicenseFeatureKey key, {T? defaultValue}) async {
    await _ensureInitialized();

    // Если это продвинутые функции, доступные только в Pro,
    // и лицензия не валидна или не Pro - возвращаем значение для Standard
    if (_isProOnlyFeature(key) && (!_isLicenseValid || _cachedLicense?.type != LicenseType.pro)) {
      // Получаем значение для Standard лицензии
      return LicenseFeatureSet.getDefaultValueForType<T>(key, LicenseType.standard);
    }

    return _featureSet!.getFeatureValue<T>(key, defaultValue: defaultValue);
  }

  /// Проверяет, находится ли значение в пределах лимита, установленного лицензией
  Future<bool> isWithinLimit(LicenseFeatureKey key, int currentValue) async {
    await _ensureInitialized();

    // Если это продвинутые количественные функции, доступные только в Pro,
    // и лицензия не валидна или не Pro - используем лимит Standard
    if (_isProOnlyFeature(key) && (!_isLicenseValid || _cachedLicense?.type != LicenseType.pro)) {
      final standardLimit = LicenseFeatureSet.getDefaultValueForType<int>(
        key,
        LicenseType.standard,
      );
      return standardLimit == -1 || currentValue <= standardLimit;
    }

    return _featureSet!.isWithinLimit(key, currentValue);
  }

  /// Убеждается, что сервис инициализирован
  Future<void> _ensureInitialized() async {
    if (_featureSet == null) {
      await _refreshLicense();
    }
  }

  /// Обновляет информацию о лицензии (вызывается после изменения лицензии)
  Future<void> refreshLicense() async {
    await _refreshLicense();
  }

  /// Возвращает текущий тип лицензии
  Future<LicenseType> getCurrentLicenseType() async {
    await _ensureInitialized();

    // Если лицензия невалидна, но она типа Pro, возвращаем Standard
    if (!_isLicenseValid && _cachedLicense?.type == LicenseType.pro) {
      return LicenseType.standard;
    }

    return _cachedLicense?.type ?? LicenseType.standard;
  }

  /// Возвращает текущую лицензию
  Future<License?> getCurrentLicense() async {
    await _ensureInitialized();
    return _cachedLicense;
  }

  /// Проверяет, есть ли активная лицензия
  Future<bool> hasActiveLicense() async {
    await _ensureInitialized();
    return _isLicenseValid && _cachedLicense != null;
  }

  /// Проверяет, является ли текущая лицензия валидной
  Future<bool> isLicenseValid() async {
    await _ensureInitialized();
    return _isLicenseValid;
  }

  /// Проверяет, является ли текущая лицензия просроченной
  Future<bool> isLicenseExpired() async {
    await _ensureInitialized();
    return _isLicenseExpired;
  }

  /// Возвращает статус лицензии для отображения пользователю
  Future<LicenseStatusType> getLicenseStatusType() async {
    await _ensureInitialized();

    if (_cachedLicense == null) {
      return LicenseStatusType.notFound;
    }

    if (_isLicenseValid) {
      return LicenseStatusType.valid;
    }

    if (_isLicenseExpired) {
      return LicenseStatusType.expired;
    }

    return LicenseStatusType.invalid;
  }
}

/// Типы статуса лицензии для отображения пользователю
enum LicenseStatusType {
  /// Лицензия не найдена
  notFound,

  /// Лицензия действительна
  valid,

  /// Лицензия просрочена
  expired,

  /// Лицензия недействительна (например, неверная подпись)
  invalid,
}
