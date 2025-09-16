// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListItem extends StatelessWidget {
  const PaymentListItem({super.key, required this.payment, this.mediateSummary, this.onPressed});

  final Payment payment;
  final num? mediateSummary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isCorrection = payment.type == PaymentType.correction;
    final shouldGrayscale = !payment.isEnabled || payment.isDone;
    final hasNegativeBalance = mediateSummary != null && mediateSummary! < 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: shouldGrayscale ? 0 : 1,
      color: _getCardColor(context, shouldGrayscale, hasNegativeBalance, isCorrection),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, shouldGrayscale, hasNegativeBalance, isCorrection),
              const SizedBox(height: 8),
              _buildFooter(context, shouldGrayscale, isCorrection),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool shouldGrayscale,
    bool hasNegativeBalance,
    bool isCorrection,
  ) {
    final textColor = shouldGrayscale ? context.color.onSurfaceVariant : context.color.onSurface;
    final statusIcon = _getStatusIcon(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Иконка типа платежа или предупреждения
        Icon(
          _getPaymentIcon(hasNegativeBalance, isCorrection),
          size: 18,
          color: _getIconColor(
            context,
            shouldGrayscale,
            hasNegativeBalance,
            isCorrection,
            textColor,
          ),
        ),
        const SizedBox(width: 8),

        // Название платежа
        Expanded(
          child: Text(
            isCorrection ? 'Коррекция баланса' : payment.details.name,
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
    );
  }

  Widget _buildFooter(BuildContext context, bool shouldGrayscale, bool isCorrection) {
    final textColor = shouldGrayscale ? context.color.onSurfaceVariant : context.color.onSurface;
    final repeatWidget = _buildRepeatWidget(context, shouldGrayscale, textColor);
    final budgetPredictWidget = _buildBudgetWidget(context);

    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Сумма платежа
            Visibility(
              visible: !isCorrection,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: _buildMoneyWidget(
                context,
                payment.normalizedMoney,
                payment.details.currency,
                shouldGrayscale,
                textColor,
              ),
            ),
            // Повторяющийся платеж
            repeatWidget,
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
    );
  }

  Widget _buildBudgetWidget(BuildContext context) {
    if (mediateSummary == null) return const SizedBox();

    return MoneyColoredWidget(
      value: mediateSummary,
      currency: payment.details.currency,
      showPlusSign: false,
      overridePositiveColor: context.color.tertiary,
      overrideNegativeColor: context.color.error,
      textStyle: context.theme.textTheme.bodyMedium?.copyWith(
        fontWeight: mediateSummary! < 0 ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  Widget? _getStatusIcon(BuildContext context) {
    if (!payment.isEnabled) {
      return Icon(
        Icons.power_settings_new_rounded,
        size: 18,
        color: context.ext<MoniplanExtraColors>()?.moneyNegative,
      );
    } else if (payment.isDone) {
      return Icon(
        Icons.check_circle_outline_rounded,
        size: 18,
        color: context.ext<MoniplanExtraColors>()?.moneyPositive,
      );
    }
    return null;
  }

  IconData _getPaymentIcon(bool hasNegativeBalance, bool isCorrection) {
    if (hasNegativeBalance) return Icons.warning_amber_rounded;
    if (isCorrection) return Icons.sync_alt;
    return payment.type == PaymentType.income
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
  }

  Color _getIconColor(
    BuildContext context,
    bool shouldGrayscale,
    bool hasNegativeBalance,
    bool isCorrection,
    Color textColor,
  ) {
    if (shouldGrayscale) return textColor;
    if (hasNegativeBalance) return context.color.error;
    if (isCorrection) return Colors.yellowAccent;

    return payment.type == PaymentType.income
        ? context.ext<MoniplanExtraColors>()?.moneyPositive ?? Colors.green
        : context.ext<MoniplanExtraColors>()?.moneyNegative ?? Colors.red;
  }

  Color _getCardColor(
    BuildContext context,
    bool shouldGrayscale,
    bool hasNegativeBalance,
    bool isCorrection,
  ) {
    if (isCorrection) return context.color.surfaceContainerHighest;
    if (shouldGrayscale) return context.color.surfaceContainerLowest;
    if (hasNegativeBalance) return context.color.errorContainer.withValues(alpha: .2);

    return payment.type == PaymentType.income
        ? context.color.primaryContainer.withValues(alpha: .4)
        : context.color.surfaceContainer;
  }

  Widget _buildRepeatWidget(BuildContext context, bool shouldGrayscale, Color textColor) {
    if (!payment.isRepeat) return const SizedBox();

    return Row(
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
    );
  }

  Widget _buildMoneyWidget(
    BuildContext context,
    num value,
    CurrencyData currency,
    bool shouldGrayscale,
    Color textColor,
  ) {
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
    final IconData icon =
        isNegative ? Icons.warning_amber_rounded : Icons.account_balance_wallet_outlined;
    final color = isNegative ? context.color.error : context.color.tertiary;

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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 16, color: color), const SizedBox(width: 4), budgetPredictWidget],
    );
  }
}
