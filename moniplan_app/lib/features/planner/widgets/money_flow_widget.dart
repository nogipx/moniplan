// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class MoneyFlowWidget extends StatelessWidget {
  final MoneyFlowUseCaseResult state;

  const MoneyFlowWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Определяем тренд баланса (положительный или отрицательный)
    final balanceTrend = state.balance >= state.initialBalance;
    final trendIcon = balanceTrend ? Icons.trending_up : Icons.trending_down;
    final trendColor =
        balanceTrend
            ? context.ext<MoniplanExtraColors>()?.moneyPositive
            : context.ext<MoniplanExtraColors>()?.moneyNegative;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            balanceTrend
                ? context.color.surfaceContainerHighest
                : context.color.errorContainer.withOpacity(0.3),
            balanceTrend
                ? context.color.surfaceContainerHigh
                : context.color.errorContainer.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color:
                balanceTrend
                    ? context.color.shadow.withOpacity(0.1)
                    : context.color.error.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Верхний ряд: Начальный баланс и Итоговый баланс
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildItem(
                  context,
                  'Start',
                  state.initialBalance,
                  CurrencyDataCommon.rub,
                  showPlusSign: false,
                  isHighlighted: false,
                ),
                Row(
                  children: [
                    _buildItem(
                      context,
                      'Result',
                      state.balance,
                      CurrencyDataCommon.rub,
                      showPlusSign: false,
                      isHighlighted: true,
                    ),
                    const SizedBox(width: 4),
                    Icon(trendIcon, color: trendColor, size: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Нижний ряд: Доходы и Расходы
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildItem(
                    context,
                    'Income',
                    state.totalIncome,
                    CurrencyDataCommon.rub,
                    showPlusSign: true,
                    isIncome: true,
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: context.color.outlineVariant,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: _buildItem(
                    context,
                    'Expense',
                    state.totalOutcome,
                    CurrencyDataCommon.rub,
                    showPlusSign: false,
                    isIncome: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String label,
    num value,
    CurrencyData currency, {
    bool showPlusSign = false,
    bool isHighlighted = false,
    bool? isIncome,
  }) {
    final textStyle = context.theme.textTheme.labelMedium;
    final valueStyle = context.theme.textTheme.titleMedium?.copyWith(
      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
      color: isHighlighted ? context.color.primary : null,
    );

    Color? overrideColor;
    if (isIncome != null) {
      overrideColor =
          isIncome
              ? context.ext<MoniplanExtraColors>()?.moneyPositive
              : context.ext<MoniplanExtraColors>()?.moneyNegative;
    }

    final moneyWidget = MoneyColoredWidget(
      value: value,
      currency: currency,
      showPlusSign: showPlusSign,
      textStyle: valueStyle,
      overridePositiveColor: overrideColor,
      overrideNegativeColor: isHighlighted && value < 0 ? context.color.error : overrideColor,
    );

    // Если это выделенный элемент (Result), добавляем анимацию
    if (isHighlighted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textStyle?.copyWith(color: context.color.primary)),
          const SizedBox(height: 2),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.95, end: 1.05),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: moneyWidget);
            },
          ),
        ],
      );
    }

    // Для обычных элементов
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textStyle?.copyWith(color: context.color.onSurfaceVariant)),
        const SizedBox(height: 2),
        moneyWidget,
      ],
    );
  }
}
