// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/planner/_index.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListSeparator extends StatelessWidget {
  final DateTime currDate;
  final List<Payment>? payments;
  final DateTime today;
  final double animationValue;
  final double stuckAmount;
  final bool isMonthEdge;
  final bool showDaySeparator;

  const PaymentListSeparator({
    required this.today,
    required this.currDate,
    this.payments,
    this.animationValue = 0,
    this.stuckAmount = 0,
    this.isMonthEdge = false,
    this.showDaySeparator = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const shrink = SizedBox.shrink();

    return RepaintBoundary(
      child: Container(
        color: context.color.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isMonthEdge) const SizedBox(height: 16),
            if (isMonthEdge)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: context.color.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat(DateFormat.MONTH).format(currDate).capitalize(),
                      style: context.text.titleLarge?.copyWith(
                        color: context.color.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currDate.year.toString(),
                      style: context.text.titleMedium?.copyWith(
                        color: context.color.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.color.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${currDate.month}/12',
                        style: context.text.labelSmall?.copyWith(
                          color: context.color.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (isMonthEdge)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Divider(color: context.color.outlineVariant),
              ),
            if (showDaySeparator)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: shrink),
                    PaymentListDaySeparator(date: currDate, today: today),
                    Expanded(child: shrink),
                  ],
                ),
              ),
            if (payments != null && payments!.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      size: 14,
                      color: context.color.outlineVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Нет платежей',
                      style: context.text.bodySmall?.copyWith(
                        color: context.color.outlineVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
