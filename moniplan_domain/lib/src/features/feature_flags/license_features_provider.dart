// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:feature_core/feature_core.dart';
import 'package:moniplan_domain/src/features/feature_flags/features.dart';
import 'package:moniplan_domain/src/features/feature_flags/license_features_service.dart';

/// Провайдер фичей на основе лицензии
final class LicenseFeaturesProvider extends FeaturesProvider {
  final LicenseFeaturesService _licenseFeaturesService;

  LicenseFeaturesProvider(this._licenseFeaturesService)
    : super(key: 'license_features_provider', name: 'License Features Provider');

  @override
  Future<List<FeatureAbstract>> pullFeatures() async {
    // Получаем все значения для фичей
    final features = <FeatureAbstract>[
      // Boolean features
      EnableAdvancedAnalytics(
        await _licenseFeaturesService.hasFeature(FeatureKeys.enableAdvancedAnalytics),
      ),
      EnableAiPredictions(
        await _licenseFeaturesService.hasFeature(FeatureKeys.enableAiPredictions),
      ),
      EnableAutoCategories(
        await _licenseFeaturesService.hasFeature(FeatureKeys.enableAutoCategories),
      ),

      // Integer features
      MaxCategories(await _licenseFeaturesService.getFeatureValue<int>(FeatureKeys.maxCategories)),
      MaxPayments(await _licenseFeaturesService.getFeatureValue<int>(FeatureKeys.maxPayments)),
      MaxAccounts(await _licenseFeaturesService.getFeatureValue<int>(FeatureKeys.maxAccounts)),
      MaxPaymentTemplates(
        await _licenseFeaturesService.getFeatureValue<int>(FeatureKeys.maxPaymentTemplates),
      ),
    ];

    return features;
  }

  /// Обновляет фичи после изменения лицензии
  Future<void> refreshFeatures() async {
    await _licenseFeaturesService.refreshLicense();
    requestPullFeatures();
  }
}
