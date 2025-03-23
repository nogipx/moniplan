// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:feature_core/feature_core.dart';
import 'package:flutter/material.dart';
import 'package:moniplan_app/core/di_get_it/_index.dart';
import 'package:moniplan_app/features/license/ui/components/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Страница для отображения доступных фичей в красивом формате
class FeatureDisplayPage extends StatelessWidget {
  const FeatureDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final featuresManager = AppDi.instance.getFeaturesManager();
    final features = featuresManager.features.values.toList();
    final theme = Theme.of(context);

    // Сортируем фичи: сначала булевы (включенные, затем выключенные), потом числовые
    features.sort((a, b) {
      if (a.value is bool && b.value is bool) {
        final aValue = a.value as bool;
        final bValue = b.value as bool;
        return bValue == aValue ? 0 : (bValue ? 1 : -1);
      } else if (a.value is bool) {
        return -1;
      } else if (b.value is bool) {
        return 1;
      } else if (a.value is int && b.value is int) {
        final aValue = a.value as int;
        final bValue = b.value as int;
        if (aValue < 0 && bValue < 0) {
          return 0;
        } else if (aValue < 0) {
          return -1;
        } else if (bValue < 0) {
          return 1;
        } else {
          return bValue.compareTo(aValue);
        }
      }
      return 0;
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Возможности вашей лицензии', style: context.text.displaySmall),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            onPressed: () async {
              await featuresManager.forceReloadFeatures();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Список возможностей обновлен',
                      style: context.text.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            tooltip: 'Обновить список возможностей',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Доступные функции', style: context.text.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Список функций, доступных с вашей текущей лицензией',
              style: context.text.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: features.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final feature = features[index];
                return FeatureStatusCard(feature: feature);
              },
            ),
          ],
        ),
      ),
    );
  }
}
