// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:licensify/licensify.dart';
import 'package:moniplan_domain/src/features/feature_flags/features.dart';
import 'package:moniplan_domain/src/features/license/i_moniplan_license_repository.dart';

/// Сервис для управления функциями, доступными на основе текущей лицензии
class LicenseFeaturesService {
  final IMoniplanLicenseRepo _licenseRepo;
  License? _cachedLicense;
  bool _isLicenseValid = false;
  bool _isLicenseExpired = false;
  bool _isLicenseWrongDevice = false;

  /// Конструктор
  LicenseFeaturesService(this._licenseRepo);

  /// Инициализирует сервис, загружая текущую лицензию
  Future<void> initialize() async {
    await _refreshLicense();
  }

  /// Обновляет кэшированную лицензию
  Future<void> _refreshLicense() async {
    final result = await _licenseRepo.getLicenseStatus();
    final license = result.license;
    final status = result.status;
    // Сбрасываем состояния
    _isLicenseValid = false;
    _isLicenseExpired = false;
    _isLicenseWrongDevice = false;

    if (license != null) {
      _cachedLicense = license;

      // Проверяем статус лицензии
      if (status.isActive) {
        _isLicenseValid = true;
      } else if (license.isExpired) {
        _isLicenseExpired = true;
      } else if (status is ErrorLicenseStatus && status.message.contains('deviceHash')) {
        _isLicenseWrongDevice = true;
      }
    } else {
      _cachedLicense = null;
    }
  }

  /// Проверяет, доступна ли определенная фича в текущей лицензии
  Future<bool> hasFeature(FeatureKeys featureKey) async {
    await _ensureInitialized();

    // Если это продвинутые функции, доступные только в Pro,
    // и лицензия не валидна или не Pro - запрещаем
    if (_isProOnlyFeature(featureKey) &&
        (!_isLicenseValid || _cachedLicense?.type != LicenseType.pro)) {
      return false;
    }

    // В зависимости от типа лицензии
    final licenseType = await getCurrentLicenseType();
    return _isFeatureEnabledForType(featureKey, licenseType);
  }

  /// Проверяет, является ли функция доступной только в Pro-версии
  bool _isProOnlyFeature(FeatureKeys featureKey) {
    // Эти функции доступны только в Pro-версии
    final proOnlyFeatures = [
      FeatureKeys.enableAdvancedAnalytics,
      FeatureKeys.enableAiPredictions,
      FeatureKeys.enableAutoCategories,
    ];

    return proOnlyFeatures.contains(featureKey);
  }

  /// Проверяет, доступна ли фича для определенного типа лицензии
  bool _isFeatureEnabledForType(FeatureKeys featureKey, LicenseType licenseType) {
    switch (featureKey) {
      case FeatureKeys.enableAdvancedAnalytics:
      case FeatureKeys.enableAiPredictions:
      case FeatureKeys.enableAutoCategories:
        return licenseType == LicenseType.pro;
      default:
        return true;
    }
  }

  /// Получает значение конкретной фичи для текущей лицензии
  Future<T> getFeatureValue<T>(FeatureKeys featureKey) async {
    await _ensureInitialized();

    // Если это продвинутые функции, доступные только в Pro,
    // и лицензия не валидна или не Pro - возвращаем значение для Standard
    if (_isProOnlyFeature(featureKey) &&
        (!_isLicenseValid || _cachedLicense?.type != LicenseType.pro)) {
      return _getDefaultValueForType(featureKey, LicenseType.standard) as T;
    }

    final licenseType = await getCurrentLicenseType();
    return _getDefaultValueForType(featureKey, licenseType) as T;
  }

  /// Проверяет, находится ли значение в пределах лимита, установленного лицензией
  Future<bool> isWithinLimit(FeatureKeys featureKey, int currentValue) async {
    await _ensureInitialized();

    // Если это продвинутые количественные функции, доступные только в Pro,
    // и лицензия не валидна или не Pro - используем лимит Standard
    if (_isProOnlyFeature(featureKey) &&
        (!_isLicenseValid || _cachedLicense?.type != LicenseType.pro)) {
      final standardLimit = _getDefaultValueForType(featureKey, LicenseType.standard);
      if (standardLimit is int) {
        return standardLimit == -1 || currentValue <= standardLimit;
      }
      return false;
    }

    final licenseType = await getCurrentLicenseType();
    final limit = _getDefaultValueForType(featureKey, licenseType);
    if (limit is int) {
      return limit == -1 || currentValue <= limit;
    }
    return false;
  }

  /// Возвращает значение по умолчанию для фичи в зависимости от типа лицензии
  dynamic _getDefaultValueForType(FeatureKeys featureKey, LicenseType licenseType) {
    switch (featureKey) {
      case FeatureKeys.enableAdvancedAnalytics:
        return licenseType == LicenseType.pro;
      case FeatureKeys.enableAiPredictions:
        return licenseType == LicenseType.pro;
      case FeatureKeys.enableAutoCategories:
        return licenseType == LicenseType.pro;
      case FeatureKeys.maxCategories:
        return _getCategoriesLimit(licenseType);
      case FeatureKeys.maxPayments:
        return _getPaymentsLimit(licenseType);
      case FeatureKeys.maxAccounts:
        return _getAccountsLimit(licenseType);
      case FeatureKeys.maxPaymentTemplates:
        return _getPaymentTemplatesLimit(licenseType);
      default:
        return null;
    }
  }

  int _getCategoriesLimit(LicenseType licenseType) {
    switch (licenseType) {
      case LicenseType.trial:
        return 5;
      case LicenseType.standard:
        return 10;
      case LicenseType.pro:
        return -1; // Неограниченно
      default:
        return 5;
    }
  }

  int _getPaymentsLimit(LicenseType licenseType) {
    switch (licenseType) {
      case LicenseType.trial:
        return 50;
      case LicenseType.standard:
        return 100;
      case LicenseType.pro:
        return -1; // Неограниченно
      default:
        return 50;
    }
  }

  int _getAccountsLimit(LicenseType licenseType) {
    switch (licenseType) {
      case LicenseType.trial:
        return 2;
      case LicenseType.standard:
        return 3;
      case LicenseType.pro:
        return -1; // Неограниченно
      default:
        return 2;
    }
  }

  int _getPaymentTemplatesLimit(LicenseType licenseType) {
    switch (licenseType) {
      case LicenseType.trial:
        return 3;
      case LicenseType.standard:
        return 5;
      case LicenseType.pro:
        return -1; // Неограниченно
      default:
        return 3;
    }
  }

  /// Убеждается, что сервис инициализирован
  Future<void> _ensureInitialized() async {
    if (_cachedLicense == null) {
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

    if (_isLicenseWrongDevice) {
      return LicenseStatusType.wrongDevice;
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

  /// Лицензия недействительна из-за несоответствия устройству
  wrongDevice,

  /// Лицензия недействительна (например, неверная подпись)
  invalid,
}
