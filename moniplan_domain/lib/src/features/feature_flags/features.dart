// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: missing_override_of_must_be_overridden

import 'package:feature_core/feature_core.dart';

/// Ключи для всех фичей приложения
enum FeatureKeys {
  /// Включение продвинутой аналитики
  enableAdvancedAnalytics,

  /// Включение AI-предсказаний
  enableAiPredictions,

  /// Автоматическое определение категорий
  enableAutoCategories,

  /// Максимальное количество категорий
  maxCategories,

  /// Максимальное количество платежей
  maxPayments,

  /// Максимальное количество счетов
  maxAccounts,

  /// Максимальное количество шаблонов платежей
  maxPaymentTemplates,
}

/// Базовый класс для фичи Moniplan
sealed class MoniplanFeature<T> extends FeatureGeneric<T> {
  MoniplanFeature({required FeatureKeys featureKey, required super.value})
    : super(key: featureKey.name);
}

/// Фича для включения продвинутой аналитики
final class EnableAdvancedAnalytics extends MoniplanFeature<bool> {
  EnableAdvancedAnalytics(bool value)
    : super(featureKey: FeatureKeys.enableAdvancedAnalytics, value: value);
}

/// Фича для включения AI-предсказаний
final class EnableAiPredictions extends MoniplanFeature<bool> {
  EnableAiPredictions(bool value)
    : super(featureKey: FeatureKeys.enableAiPredictions, value: value);
}

/// Фича для включения автоматического определения категорий
final class EnableAutoCategories extends MoniplanFeature<bool> {
  EnableAutoCategories(bool value)
    : super(featureKey: FeatureKeys.enableAutoCategories, value: value);
}
