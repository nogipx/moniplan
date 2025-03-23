// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:feature_core/feature_core.dart';
import 'package:moniplan_domain/src/features/feature_flags/features.dart';
import 'package:moniplan_domain/src/features/feature_flags/license_features_provider.dart';
import 'package:moniplan_domain/src/features/feature_flags/license_features_service.dart';

/// Синглтон-менеджер фичей приложения
class MoniplanFeaturesManager implements IFeaturesManager {
  @override
  MappedFeatures get features => _featuresManager.features;

  @override
  Stream<MappedFeatures> get featuresStream => _featuresManager.featuresStream;

  /// Экземпляр менеджера фичей
  final FeaturesManager _featuresManager;

  MoniplanFeaturesManager({required LicenseFeaturesService licenseFeaturesService})
    : _featuresManager = FeaturesManager(
        providers: [LicenseFeaturesProvider(licenseFeaturesService)],
      );

  /// Проверяет, включена ли фича для продвинутой аналитики
  bool isAdvancedAnalyticsEnabled() {
    final key = FeatureKeys.enableAdvancedAnalytics.name;
    final feature = _featuresManager.getFeature(key) as EnableAdvancedAnalytics?;
    return feature?.value ?? false;
  }

  /// Проверяет, включена ли фича для AI-предсказаний
  bool isAiPredictionsEnabled() {
    final key = FeatureKeys.enableAiPredictions.name;
    final feature = _featuresManager.getFeature(key) as EnableAiPredictions?;
    return feature?.value ?? false;
  }

  /// Проверяет, включена ли фича для автоматического определения категорий
  bool isAutoCategoriesEnabled() {
    final key = FeatureKeys.enableAutoCategories.name;
    final feature = _featuresManager.getFeature(key) as EnableAutoCategories?;
    return feature?.value ?? false;
  }

  /// Возвращает максимальное количество категорий
  int getMaxCategories() {
    final key = FeatureKeys.maxCategories.name;
    final feature = _featuresManager.getFeature(key) as MaxCategories?;
    return feature?.value ?? 5;
  }

  /// Возвращает максимальное количество платежей
  int getMaxPayments() {
    final key = FeatureKeys.maxPayments.name;
    final feature = _featuresManager.getFeature(key) as MaxPayments?;
    return feature?.value ?? 50;
  }

  /// Возвращает максимальное количество счетов
  int getMaxAccounts() {
    final key = FeatureKeys.maxAccounts.name;
    final feature = _featuresManager.getFeature(key) as MaxAccounts?;
    return feature?.value ?? 2;
  }

  /// Возвращает максимальное количество шаблонов платежей
  int getMaxPaymentTemplates() {
    final key = FeatureKeys.maxPaymentTemplates.name;
    final feature = _featuresManager.getFeature(key) as MaxPaymentTemplates?;
    return feature?.value ?? 3;
  }

  /// Проверяет, находится ли значение в пределах лимита категорий
  bool isWithinCategoriesLimit(int currentCount) {
    final limit = getMaxCategories();
    return limit == -1 || currentCount < limit;
  }

  /// Проверяет, находится ли значение в пределах лимита платежей
  bool isWithinPaymentsLimit(int currentCount) {
    final limit = getMaxPayments();
    return limit == -1 || currentCount < limit;
  }

  /// Проверяет, находится ли значение в пределах лимита счетов
  bool isWithinAccountsLimit(int currentCount) {
    final limit = getMaxAccounts();
    return limit == -1 || currentCount < limit;
  }

  /// Проверяет, находится ли значение в пределах лимита шаблонов платежей
  bool isWithinPaymentTemplatesLimit(int currentCount) {
    final limit = getMaxPaymentTemplates();
    return limit == -1 || currentCount < limit;
  }

  @override
  void clearOverrides({String? key}) {
    _featuresManager.clearOverrides(key: key);
  }

  @override
  void dispose() {
    _featuresManager.dispose();
  }

  @override
  FeatureAbstract? getFeature(String key) {
    return _featuresManager.getFeature(key);
  }

  @override
  bool isOverridden(String key) {
    return _featuresManager.isOverridden(key);
  }

  @override
  void overrideFeature(FeatureAbstract feature) {
    _featuresManager.overrideFeature(feature);
  }

  @override
  Future<void> forceReloadFeatures() {
    return _featuresManager.forceReloadFeatures();
  }
}
