// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/features/planner/dialogs/day_summary_dialog.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListDaySeparator extends StatelessWidget {
  final DateTime date;
  final DateTime today;

  const PaymentListDaySeparator({required this.date, required this.today, super.key});

  @override
  Widget build(BuildContext context) {
    final isSameDay = today.isSameDay(date);
    final isSameYear = today.year == date.year;

    return GestureDetector(
      onLongPress: () {
        _showDaysInfo(context);
      },
      onTap: () {
        _showDaySummary(context);
      },
      behavior: HitTestBehavior.opaque,
      child: AppContourAnimation(
        isAnimated: isSameDay,
        customColor: context.color.surfaceTint,
        borderRadius: AppRadius.r8.value,
        duration: const Duration(seconds: 2),
        edgeInsets: const EdgeInsets.all(1.4),
        minFraction: .39,
        maxFraction: .45,
        child: Container(
          decoration: BoxDecoration(
            color: isSameDay ? context.color.surfaceTint : context.color.surfaceContainer,
            borderRadius: BorderRadius.all(AppRadius.r10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                child: Text(
                  isSameYear
                      ? DateFormat.MMMMd().format(date)
                      : DateFormat('d MMMM y').format(date),
                  style: context.text.labelMedium?.copyWith(
                    color: isSameDay ? context.color.onInverseSurface : context.color.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDaysInfo(BuildContext context) {
    final difference = date.difference(today).inDays;
    final absValue = difference.abs();

    String message;
    if (difference == 0) {
      message = 'Сегодня';
    } else if (difference > 0) {
      message = 'Через $absValue ${_getDaysForm(absValue)}';
    } else {
      message = '$absValue ${_getDaysForm(absValue)} назад';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDaySummary(BuildContext context) {
    final plannerState = context.read<PlannerBloc>().state;

    if (plannerState is! PlannerBudgetComputedState) {
      return;
    }

    // Находим платежи за выбранный день
    final dayPayments = plannerState.payments.where((p) => p.date.isSameDay(date)).toList();

    // Вычисляем доходы и расходы за день
    num dayIncome = 0;
    num dayOutcome = 0;

    for (final payment in dayPayments) {
      if (payment.type == PaymentType.income) {
        dayIncome += payment.normalizedMoney;
      } else if (payment.type == PaymentType.expense) {
        dayOutcome += payment.normalizedMoney.abs();
      }
    }

    final dayBalance = dayIncome - dayOutcome;
    final totalBalance = plannerState.moneyFlow.balance;

    DaySummaryDialog.show(
      context: context,
      date: date,
      payments: dayPayments,
      dayIncome: dayIncome,
      dayOutcome: dayOutcome,
      dayBalance: dayBalance,
      totalBalance: totalBalance,
    );
  }

  String _getDaysForm(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(days % 10) && ![12, 13, 14].contains(days % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }
}
