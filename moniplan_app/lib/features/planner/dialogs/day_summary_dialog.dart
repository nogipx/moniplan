// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class DaySummaryDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM y');
    final moneyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сводка за ${dateFormat.format(date)}',
              style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              'Доходы за день:',
              moneyFormat.format(dayIncome),
              color: Colors.green,
            ),
            _buildSummaryItem(
              context,
              'Расходы за день:',
              moneyFormat.format(dayOutcome),
              color: Colors.red,
            ),
            _buildSummaryItem(
              context,
              'Баланс за день:',
              moneyFormat.format(dayBalance),
              color: dayBalance >= 0 ? Colors.green : Colors.red,
            ),
            const Divider(height: 24),
            _buildSummaryItem(
              context,
              'Общий баланс:',
              moneyFormat.format(totalBalance),
              color: totalBalance >= 0 ? Colors.green : Colors.red,
              isBold: true,
            ),
            const SizedBox(height: 16),
            if (payments.isEmpty)
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
                  ...payments.map((payment) => _buildPaymentItem(context, payment)),
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

  Widget _buildPaymentItem(BuildContext context, Payment payment) {
    final moneyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    final isIncome = payment.type == PaymentType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';
    final amount = moneyFormat.format(payment.normalizedMoney.abs());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              payment.details.name,
              style: context.text.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('$sign$amount', style: context.text.bodyMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}
