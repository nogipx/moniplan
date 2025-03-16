// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListItem extends StatelessWidget {
  const PaymentListItem({super.key, required this.payment, this.mediateSummary, this.onPressed});

  final Payment payment;
  final num? mediateSummary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final shouldGrayscale = !payment.isEnabled || payment.isDone;
    final isIncome = payment.type == PaymentType.income;

    // Проверяем, отрицательный ли баланс
    final hasNegativeBalance = mediateSummary != null && mediateSummary! < 0;

    // Определяем цвета в зависимости от баланса и состояния
    final cardColor =
        shouldGrayscale
            ? context.color.surfaceContainerLowest
            : hasNegativeBalance
            ? context.color.errorContainer.withValues(alpha: .2)
            : isIncome
            ? context.color.primaryContainer.withValues(alpha: .4)
            : context.color.surfaceContainerLow;

    final textColor = shouldGrayscale ? context.color.onSurfaceVariant : context.color.onSurface;

    final budgetPredictWidget =
        mediateSummary != null
            ? MoneyColoredWidget(
              value: mediateSummary,
              currency: payment.details.currency,
              showPlusSign: false,
              overridePositiveColor: context.color.tertiary,
              overrideNegativeColor: context.color.error,
              textStyle: context.theme.textTheme.bodyMedium?.copyWith(
                fontWeight: mediateSummary! < 0 ? FontWeight.w700 : FontWeight.w500,
              ),
            )
            : const SizedBox();

    final repeatWidget =
        payment.isRepeat
            ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  payment.repeat.shortName,
                  style: context.theme.textTheme.labelMedium?.copyWith(
                    color: shouldGrayscale ? textColor : context.color.primary,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: shouldGrayscale ? textColor : context.color.primary,
                ),
              ],
            )
            : const SizedBox();

    final statusIcon =
        !payment.isEnabled
            ? Icon(
              Icons.power_settings_new_rounded,
              size: 18,
              color: context.ext<MoniplanExtraColors>()?.moneyNegative,
            )
            : payment.isDone
            ? Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: context.ext<MoniplanExtraColors>()?.moneyPositive,
            )
            : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: shouldGrayscale ? 0 : 1,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            shouldGrayscale
                ? BorderSide(color: context.color.outlineVariant, width: 0.5)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Иконка типа платежа или предупреждения
                  Icon(
                    hasNegativeBalance
                        ? Icons.warning_amber_rounded
                        : isIncome
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 18,
                    color:
                        shouldGrayscale
                            ? textColor
                            : hasNegativeBalance
                            ? context.color.error
                            : isIncome
                            ? context.ext<MoniplanExtraColors>()?.moneyPositive
                            : context.ext<MoniplanExtraColors>()?.moneyNegative,
                  ),
                  const SizedBox(width: 8),

                  // Название платежа
                  Expanded(
                    child: Text(
                      payment.details.name,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Статус платежа (если есть)
                  if (statusIcon != null) ...[const SizedBox(width: 4), statusIcon],
                ],
              ),

              const SizedBox(height: 8),

              // Нижняя часть с суммой и дополнительной информацией
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Сумма платежа
                      _buildMoneyWidget(
                        context,
                        payment.normalizedMoney,
                        payment.details.currency,
                        shouldGrayscale,
                        textColor,
                      ),

                      Row(
                        children: [
                          // Индикатор повторяющегося платежа
                          repeatWidget,

                          // Прогноз бюджета
                        ],
                      ),
                    ],
                  ),
                  if (payment.isEnabled && mediateSummary != null) ...[
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildBudgetPredict(context, mediateSummary!, budgetPredictWidget),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoneyWidget(
    BuildContext context,
    num value,
    CurrencyData currency,
    bool shouldGrayscale,
    Color textColor,
  ) {
    // Для платежей мы не подсвечиваем отрицательные значения, так как это нормально для расходов
    // Подсветка будет только в _buildBudgetPredict для отрицательного баланса

    return MoneyColoredWidget(
      value: value,
      currency: currency,
      textStyle: context.theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: shouldGrayscale ? textColor : null,
      ),
    );
  }

  Widget _buildBudgetPredict(BuildContext context, num summary, Widget budgetPredictWidget) {
    final isNegative = summary < 0;

    // Выбираем иконку и цвет в зависимости от знака баланса
    final IconData icon =
        isNegative ? Icons.warning_amber_rounded : Icons.account_balance_wallet_outlined;

    final color = isNegative ? context.color.error : context.color.tertiary;

    // Для отрицательного баланса добавляем анимацию и контейнер
    if (isNegative) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: context.color.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.color.error.withValues(alpha: 0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: context.color.error.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: Icon(icon, size: 16, color: color));
              },
            ),
            const SizedBox(width: 4),
            budgetPredictWidget,
          ],
        ),
      );
    }

    // Для положительного баланса оставляем обычное отображение
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 16, color: color), const SizedBox(width: 4), budgetPredictWidget],
    );
  }
}
