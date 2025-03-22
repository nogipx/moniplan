// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/core/di_get_it/app_di.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

/// Миксин для легкого доступа к функциям, ограниченным лицензией
mixin LicenseFeatureMixin {
  /// Сервис функций лицензии
  LicenseFeaturesService get licenseFeatures => AppDi.instance.getLicenseFeaturesService();

  /// Проверяет, доступна ли функция в текущей лицензии
  Future<bool> hasFeature(LicenseFeatureKey key) {
    return licenseFeatures.hasFeature(key);
  }

  /// Получает значение функции лицензии
  Future<T> getFeatureValue<T>(LicenseFeatureKey key, {T? defaultValue}) {
    return licenseFeatures.getFeatureValue<T>(key, defaultValue: defaultValue);
  }

  /// Проверяет, не превышен ли лимит для указанного количественного параметра
  Future<bool> isWithinLimit(LicenseFeatureKey key, int currentValue) {
    return licenseFeatures.isWithinLimit(key, currentValue);
  }

  /// Проверяет, доступна ли функция, и показывает диалог с предложением обновить лицензию,
  /// если функция недоступна
  Future<bool> checkFeatureAvailability(
    BuildContext context,
    LicenseFeatureKey key, {
    String? featureName,
    String? description,
  }) async {
    final hasAccess = await hasFeature(key);

    if (!hasAccess) {
      // Показываем диалог о недоступности функции
      if (context.mounted) {
        await _showUpgradeDialog(
          context,
          featureName ?? key.toString().split('.').last,
          description ?? 'Эта функция недоступна в вашей текущей лицензии.',
        );
      }
    }

    return hasAccess;
  }

  /// Проверяет, не превышен ли лимит, и показывает диалог с предложением обновить лицензию,
  /// если лимит превышен
  Future<bool> checkLimitAvailability(
    BuildContext context,
    LicenseFeatureKey key,
    int currentValue, {
    String? featureName,
    String? description,
  }) async {
    final withinLimit = await isWithinLimit(key, currentValue);

    if (!withinLimit) {
      final limit = await getFeatureValue<int>(key);
      final limitDescription =
          limit == -1 ? 'неограниченное количество' : '$limit ${_getUnitName(key, limit)}';

      // Показываем диалог о превышении лимита
      if (context.mounted) {
        await _showUpgradeDialog(
          context,
          featureName ?? key.toString().split('.').last,
          description ??
              'Вы достигли лимита для этой функции. '
                  'Ваша текущая лицензия позволяет: $limitDescription.',
        );
      }
    }

    return withinLimit;
  }

  /// Возвращает название единицы измерения для количественной функции
  String _getUnitName(LicenseFeatureKey key, int count) {
    final endings = {
      LicenseFeatureKey.maxPlanners: ['планер', 'планера', 'планеров'],
      LicenseFeatureKey.maxForecastMonths: ['месяц', 'месяца', 'месяцев'],
      LicenseFeatureKey.maxCategories: ['категория', 'категории', 'категорий'],
      LicenseFeatureKey.maxDevices: ['устройство', 'устройства', 'устройств'],
    };

    final forms = endings[key];
    if (forms == null) return '';

    final absCount = count.abs();
    final mod10 = absCount % 10;
    final mod100 = absCount % 100;

    if (mod10 == 1 && mod100 != 11) {
      return forms[0];
    } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return forms[1];
    } else {
      return forms[2];
    }
  }

  /// Показывает диалог с предложением обновить лицензию
  Future<void> _showUpgradeDialog(
    BuildContext context,
    String featureName,
    String description,
  ) async {
    final currentType = await licenseFeatures.getCurrentLicenseType();
    String recommendedType;

    if (currentType == LicenseType.trial) {
      recommendedType = 'Standard';
    } else if (currentType == LicenseType.standard) {
      recommendedType = 'Pro';
    } else {
      recommendedType = 'Pro';
    }

    if (context.mounted) {
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Функция недоступна: $featureName'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description),
                  const SizedBox(height: 16),
                  Text(
                    'Для доступа к этой возможности обновите свою лицензию до $recommendedType.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Понятно'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToLicensePage(context);
                  },
                  child: const Text('Управление лицензией'),
                ),
              ],
            ),
      );
    }
  }

  /// Переход на страницу управления лицензией
  void _navigateToLicensePage(BuildContext context) {
    Navigator.of(context).pushNamed('/license');
  }
}
