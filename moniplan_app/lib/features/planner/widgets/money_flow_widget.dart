// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/features/payment/usecases/money_flow_usecase.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class MoneyFlowWidget extends StatelessWidget {
  final MoneyFlowUseCaseResult state;

  const MoneyFlowWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Определяем тренд баланса (положительный или отрицательный)
    final balanceTrend = state.balance >= state.initialBalance;
    final trendIcon = balanceTrend ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final trendColor =
        balanceTrend
            ? context.ext<MoniplanExtraColors>()?.moneyPositive
            : context.ext<MoniplanExtraColors>()?.moneyNegative;

    // Проверяем наличие информации о коррекциях
    final hasCorrections = state.additionalData?['hasCorrections'] == true;
    final correctionsValue = state.additionalData?['corrections'] as num? ?? 0;

    return Card(
      elevation: 0,
      color: context.color.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.color.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.analytics_rounded, size: 18, color: context.color.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Сводная информация',
                    style: context.text.labelLarge?.copyWith(color: context.color.primary),
                  ),
                ],
              ),
            ),

            // Верхний ряд: Начальный баланс и Итоговый баланс
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildItem(
                    context,
                    'Начальный баланс',
                    Icons.account_balance_rounded,
                    state.initialBalance,
                    CurrencyDataCommon.rub,
                    showPlusSign: false,
                    isHighlighted: false,
                  ),
                  Row(
                    children: [
                      _buildItem(
                        context,
                        'Текущий баланс',
                        Icons.account_balance_wallet_rounded,
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
            ),

            const Divider(height: 24),

            // Нижний ряд: Доходы и Расходы
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildItem(
                      context,
                      'Доходы',
                      Icons.arrow_downward_rounded,
                      state.totalIncome,
                      CurrencyDataCommon.rub,
                      showPlusSign: true,
                      isIncome: true,
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: context.color.outlineVariant,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    child: _buildItem(
                      context,
                      'Расходы',
                      Icons.arrow_upward_rounded,
                      state.totalOutcome,
                      CurrencyDataCommon.rub,
                      showPlusSign: false,
                      isIncome: false,
                    ),
                  ),
                ],
              ),
            ),

            // Показываем информацию о коррекциях, если они есть
            if (hasCorrections) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildItem(
                      context,
                      'Коррекции',
                      Icons.sync_alt_rounded,
                      correctionsValue,
                      CurrencyDataCommon.rub,
                      showPlusSign: true,
                      isCorrection: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String label,
    IconData icon,
    num value,
    CurrencyData currency, {
    bool showPlusSign = false,
    bool isHighlighted = false,
    bool? isIncome,
    bool isCorrection = false,
  }) {
    final textStyle = context.text.labelMedium;
    final valueStyle = context.text.titleMedium?.copyWith(
      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
      color: isHighlighted ? context.color.primary : null,
    );

    Color? overrideColor;
    if (isCorrection) {
      // Для коррекций используем желтый цвет
      overrideColor = Colors.amber[700];
    } else if (isIncome != null) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  isCorrection
                      ? Colors.amber[700]
                      : isHighlighted
                      ? context.color.primary
                      : context.color.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: textStyle?.copyWith(
                color:
                    isCorrection
                        ? Colors.amber[700]
                        : isHighlighted
                        ? context.color.primary
                        : context.color.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (isHighlighted) ...[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.95, end: 1.05),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: moneyWidget);
            },
          ),
        ] else ...[
          moneyWidget,
        ],
      ],
    );
  }
}
