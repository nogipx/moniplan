// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class DaySummaryDialog extends StatefulWidget {
  final DateTime date;
  final List<Payment> payments;
  final num dayIncome;
  final num dayOutcome;
  final num dayBalance;
  final num totalBalance;

  const DaySummaryDialog({
    required this.date,
    required this.payments,
    required this.dayIncome,
    required this.dayOutcome,
    required this.dayBalance,
    required this.totalBalance,
    super.key,
  });

  static Future<void> show({
    required BuildContext context,
    required DateTime date,
    required List<Payment> payments,
    required num dayIncome,
    required num dayOutcome,
    required num dayBalance,
    required num totalBalance,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) => DaySummaryDialog(
            date: date,
            payments: payments,
            dayIncome: dayIncome,
            dayOutcome: dayOutcome,
            dayBalance: dayBalance,
            totalBalance: totalBalance,
          ),
    );
  }

  @override
  State<DaySummaryDialog> createState() => _DaySummaryDialogState();
}

class _DaySummaryDialogState extends State<DaySummaryDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM y');
    final moneyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    final hasDayNegativeBalance = widget.dayBalance < 0;
    final hasTotalNegativeBalance = widget.totalBalance < 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            hasTotalNegativeBalance
                ? BorderSide(color: context.color.error.withValues(alpha: 0.5), width: 2)
                : BorderSide.none,
      ),
      backgroundColor:
          hasTotalNegativeBalance ? context.color.errorContainer.withValues(alpha: 0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Сводка за ${dateFormat.format(widget.date)}',
                    style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (hasDayNegativeBalance || hasTotalNegativeBalance)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: math.pi / 12 * math.sin(_animationController.value * math.pi),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: context.color.error,
                          size: 24,
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              'Доходы за день:',
              moneyFormat.format(widget.dayIncome),
              color: context.ext<MoniplanExtraColors>()?.moneyPositive ?? Colors.green,
            ),
            _buildSummaryItem(
              context,
              'Расходы за день:',
              moneyFormat.format(widget.dayOutcome),
              color: context.ext<MoniplanExtraColors>()?.moneyNegative ?? Colors.red,
            ),
            _buildBalanceItem(
              context,
              'Баланс за день:',
              moneyFormat.format(widget.dayBalance),
              isNegative: hasDayNegativeBalance,
            ),
            const Divider(height: 24),
            _buildBalanceItem(
              context,
              'Общий баланс:',
              moneyFormat.format(widget.totalBalance),
              isNegative: hasTotalNegativeBalance,
              isBold: true,
            ),
            const SizedBox(height: 16),
            if (widget.payments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Нет платежей на этот день'),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Платежи:', style: context.text.titleMedium),
                  const SizedBox(height: 8),
                  ...widget.payments.map((payment) => _buildPaymentItem(context, payment)),
                ],
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value, {
    required Color color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.text.bodyLarge),
          Text(
            value,
            style: context.text.bodyLarge?.copyWith(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
    BuildContext context,
    String label,
    String value, {
    required bool isNegative,
    bool isBold = false,
  }) {
    final color =
        isNegative
            ? context.ext<MoniplanExtraColors>()?.moneyNegative ?? Colors.red
            : context.ext<MoniplanExtraColors>()?.moneyPositive ?? Colors.green;

    if (isNegative) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.color.errorContainer.withValues(
                alpha: 0.1 + 0.1 * _animationController.value,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withValues(alpha: 0.3 + 0.3 * _animationController.value),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      value,
                      style: context.text.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: isBold ? 18 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } else {
      return _buildSummaryItem(context, label, value, color: color, isBold: isBold);
    }
  }

  Widget _buildPaymentItem(BuildContext context, Payment payment) {
    final moneyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    final isIncome = payment.type == PaymentType.income;
    final color =
        isIncome
            ? context.ext<MoniplanExtraColors>()?.moneyPositive ?? Colors.green
            : context.ext<MoniplanExtraColors>()?.moneyNegative ?? Colors.red;
    final sign = isIncome ? '+' : '-';
    final amount = moneyFormat.format(payment.normalizedMoney.abs());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              payment.details.name,
              style: context.text.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$sign$amount',
            style: context.text.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
