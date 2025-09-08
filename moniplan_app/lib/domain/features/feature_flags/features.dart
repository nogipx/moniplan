// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: missing_override_of_must_be_overridden

import 'package:moniplan_app/domain/moniplan_domain.dart';

/// Ключи для всех фичей приложения
enum Feature { isTrialLicense, isProLicense, licenseStatus }

/// Базовый класс для фичи Moniplan
sealed class MoniplanFeature<T> extends FeatureGeneric<T> {
  MoniplanFeature({required Feature featureKey, required super.value})
    : super(key: featureKey.name);
}

/// Фича для включения AI-предсказаний
final class LicenseStatusFeature extends MoniplanFeature<LicenseStatus?> {
  LicenseStatusFeature(LicenseStatus? value)
    : super(featureKey: Feature.licenseStatus, value: value ?? NoLicenseStatus());
}

/// Фича для включения продвинутой аналитики
final class IsTrialLicense extends MoniplanFeature<bool> {
  IsTrialLicense(bool value) : super(featureKey: Feature.isTrialLicense, value: value);
}

/// Фича для включения продвинутой аналитики
final class IsProLicense extends MoniplanFeature<bool> {
  IsProLicense(bool value) : super(featureKey: Feature.isProLicense, value: value);
}
