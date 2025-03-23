// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:feature_core/feature_core.dart';
import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Виджет для отображения статуса фичи
class FeatureStatusCard extends StatelessWidget {
  /// Отображаемая фича
  final FeatureAbstract feature;

  const FeatureStatusCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _getGradient(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIcon(), color: _getIconColor(context), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getFeatureName(),
                    style: context.text.titleMedium?.copyWith(
                      color: _getTitleColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusIndicator(context),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getFeatureDescription(),
              style: context.text.bodyMedium?.copyWith(color: _getDescriptionColor(context)),
            ),
            const SizedBox(height: 16),
            _buildValueIndicator(context),
          ],
        ),
      ),
    );
  }

  /// Возвращает цвет иконки в зависимости от типа фичи
  Color _getIconColor(BuildContext context) {
    // Во всех случаях - контрастный цвет к фону
    if (_isFeatureEnabled()) {
      return context.color.onPrimaryContainer;
    } else {
      return context.color.onErrorContainer;
    }
  }

  /// Возвращает цвет заголовка в зависимости от типа фичи
  Color _getTitleColor(BuildContext context) {
    // Во всех случаях - контрастный цвет к фону
    if (_isFeatureEnabled()) {
      return context.color.onPrimaryContainer;
    } else {
      return context.color.onErrorContainer;
    }
  }

  /// Возвращает цвет описания в зависимости от типа фичи
  Color _getDescriptionColor(BuildContext context) {
    // Немного прозрачности для меньшего контраста
    if (_isFeatureEnabled()) {
      return context.color.onPrimaryContainer.withOpacity(0.8);
    } else {
      return context.color.onErrorContainer.withOpacity(0.8);
    }
  }

  /// Проверяет, включена ли фича (для булевых) или неограничена (для числовых)
  bool _isFeatureEnabled() {
    if (feature.value is bool) {
      return feature.value as bool;
    } else if (feature.value is int) {
      return (feature.value as int) < 0; // Неограниченное значение считаем "включенным"
    }
    return false;
  }

  /// Возвращает название фичи в удобочитаемом формате
  String _getFeatureName() {
    // Преобразуем camelCase в читаемый текст с пробелами и заглавной буквой
    final key = feature.key;
    final displayName = key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceFirst('enable ', 'Поддержка ')
        .replaceFirst('max ', 'Макс. кол-во ');

    return displayName.substring(0, 1).toUpperCase() + displayName.substring(1);
  }

  /// Возвращает описание фичи
  String _getFeatureDescription() {
    final featureKey = feature.key;

    if (featureKey.contains('enableAdvancedAnalytics')) {
      return 'Расширенные инструменты аналитики для детального анализа финансов';
    } else if (featureKey.contains('enableAiPredictions')) {
      return 'Прогнозирование трат с помощью искусственного интеллекта';
    } else if (featureKey.contains('enableAutoCategories')) {
      return 'Автоматическое определение категорий для ваших транзакций';
    } else if (featureKey.contains('maxCategories')) {
      return 'Количество доступных категорий для классификации расходов';
    } else if (featureKey.contains('maxPayments')) {
      return 'Количество платежей, которое можно отслеживать';
    } else if (featureKey.contains('maxAccounts')) {
      return 'Количество финансовых счетов для мониторинга';
    } else if (featureKey.contains('maxPaymentTemplates')) {
      return 'Количество сохраненных шаблонов платежей';
    }

    return 'Функция для улучшения работы с приложением';
  }

  /// Возвращает иконку для фичи
  IconData _getIcon() {
    final featureKey = feature.key;

    if (featureKey.contains('enableAdvancedAnalytics')) {
      return Icons.analytics_outlined;
    } else if (featureKey.contains('enableAiPredictions')) {
      return Icons.insights;
    } else if (featureKey.contains('enableAutoCategories')) {
      return Icons.category_outlined;
    } else if (featureKey.contains('maxCategories')) {
      return Icons.folder_outlined;
    } else if (featureKey.contains('maxPayments')) {
      return Icons.payments_outlined;
    } else if (featureKey.contains('maxAccounts')) {
      return Icons.account_balance_outlined;
    } else if (featureKey.contains('maxPaymentTemplates')) {
      return Icons.file_copy_outlined;
    }

    return Icons.featured_play_list_outlined;
  }

  /// Создает индикатор статуса (включено/выключено) для булевых фич
  Widget _buildStatusIndicator(BuildContext context) {
    if (feature.value is bool) {
      final enabled = feature.value as bool;
      final color = context.color;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? color.primary : color.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          enabled ? 'Включено' : 'Выключено',
          style: context.text.bodyMedium?.copyWith(
            color: enabled ? color.onPrimary : color.onError,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  /// Создает индикатор значения для числовых фич
  Widget _buildValueIndicator(BuildContext context) {
    if (feature.value is int) {
      final value = feature.value as int;
      final isUnlimited = value < 0;
      final color = context.color;

      // Используем более контрастные цвета для значений
      final bgColor = isUnlimited ? color.tertiary : color.secondary;
      final textColor = isUnlimited ? color.onTertiary : color.onSecondary;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isUnlimited ? Icons.all_inclusive : Icons.tag, color: textColor, size: 18),
            const SizedBox(width: 8),
            Text(
              isUnlimited ? 'Без ограничений' : value.toString(),
              style: context.text.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  /// Возвращает градиент в зависимости от типа фичи
  LinearGradient _getGradient(BuildContext context) {
    final color = context.color;

    if (feature.value is bool && feature.value == true) {
      // Для включенных булевых фич - основной цвет
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.primaryContainer, color.primaryContainer],
      );
    } else if (feature.value is bool && feature.value == false) {
      // Для выключенных булевых фич - цвет ошибки
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.errorContainer, color.errorContainer],
      );
    } else if (feature.value is int && (feature.value as int) < 0) {
      // Для неограниченных числовых фич - третичный цвет
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.tertiaryContainer, color.tertiaryContainer],
      );
    } else {
      // Для ограниченных числовых фич - вторичный цвет
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.secondaryContainer, color.secondaryContainer],
      );
    }
  }
}
