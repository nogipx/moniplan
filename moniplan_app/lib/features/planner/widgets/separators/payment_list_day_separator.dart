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

class PaymentListDaySeparator extends StatefulWidget {
  final DateTime date;
  final DateTime today;

  const PaymentListDaySeparator({required this.date, required this.today, super.key});

  @override
  State<PaymentListDaySeparator> createState() => _PaymentListDaySeparatorState();
}

class _PaymentListDaySeparatorState extends State<PaymentListDaySeparator> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isSameDay = widget.today.isSameDay(widget.date);
    final isSameYear = widget.today.year == widget.date.year;
    final isWeekend =
        widget.date.weekday == DateTime.saturday || widget.date.weekday == DateTime.sunday;

    // Определяем цвета в зависимости от типа дня (убираем подсветку проблемных дней)
    Color backgroundColor;
    Color textColor;

    if (isSameDay) {
      backgroundColor = context.color.primaryContainer;
      textColor = context.color.onPrimaryContainer;
    } else if (isWeekend) {
      backgroundColor = context.color.surfaceContainerHighest.withOpacity(0.7);
      textColor = context.color.onSurface;
    } else {
      backgroundColor = context.color.surfaceContainerHigh;
      textColor = context.color.onSurface;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () => _showDaysInfo(context),
        onTap: () => _showDaySummary(context),
        borderRadius: BorderRadius.all(AppRadius.r10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(AppRadius.r10),
            border:
                isSameDay
                    ? Border.all(color: context.color.primary.withOpacity(0.5), width: 0.5)
                    : null,
            boxShadow:
                isSameDay
                    ? [
                      BoxShadow(
                        color: context.color.primary.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSameDay)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.today_rounded, size: 16, color: textColor),
                  ),
                Text(
                  isSameYear
                      ? DateFormat.MMMMd().format(widget.date)
                      : DateFormat('d MMMM y').format(widget.date),
                  style: context.text.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: isSameDay ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                // Добавляем индикатор дня недели
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    _getWeekdayShort(widget.date),
                    style: context.text.labelSmall?.copyWith(
                      color: textColor.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDaysInfo(BuildContext context) {
    final difference = widget.date.difference(widget.today).inDays;
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
        content: Text(
          message,
          style: context.text.bodySmall?.copyWith(color: context.color.onSurface),
        ),
        backgroundColor: context.color.surfaceContainerLowest,
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
    final dayPayments = plannerState.payments.where((p) => p.date.isSameDay(widget.date)).toList();

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
      date: widget.date,
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

  String _getWeekdayShort(DateTime date) {
    final weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    // В Dart, weekday начинается с 1 (понедельник) до 7 (воскресенье)
    return weekdays[date.weekday - 1];
  }
}
