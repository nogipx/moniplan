// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// Провайдер фичей на основе лицензии
final class LicenseFeaturesProvider extends FeaturesProvider {
  final IMoniplanLicenseRepo _licenseRepo;

  LicenseFeaturesProvider(this._licenseRepo)
    : super(key: 'license_features_provider', name: 'License Features Provider');

  @override
  Future<List<FeatureAbstract>> pullFeatures() async {
    final license = await _licenseRepo.getCurrentLicense();
    final licenseStatus = await _licenseRepo.getLicenseStatus(license: license);

    final isTrialLicense = license?.isTrial ?? false;
    final isProLicense = license?.type == LicenseType.pro;

    // Получаем все значения для фичей
    final features = <FeatureAbstract>[
      IsTrialLicense(isTrialLicense),
      IsProLicense(isProLicense),
      LicenseStatusFeature(licenseStatus),
    ];

    return features;
  }
}
