// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/features/planner/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/core/_index.dart';

class PaymentListSeparator extends StatelessWidget {
  final DateTime currDate;
  final List<Payment>? payments;
  final DateTime today;
  final double animationValue;
  final double stuckAmount;
  final bool isMonthEdge;

  const PaymentListSeparator({
    required this.today,
    required this.currDate,
    this.payments,
    this.animationValue = 0,
    this.stuckAmount = 0,
    this.isMonthEdge = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const shrink = SizedBox.shrink();

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.color.surface,
              context.color.surface.withOpacity(.9),
              context.color.surface.withOpacity(0.7),
            ],
            stops: const [0, .85, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isMonthEdge) const SizedBox(height: 24),
            if (isMonthEdge)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.color.primaryContainer,
                      context.color.primary.withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.color.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.color.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: context.color.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(DateFormat.MONTH).format(currDate).capitalize(),
                              style: context.text.headlineSmall?.copyWith(
                                color: context.color.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              currDate.year.toString(),
                              style: context.text.titleMedium?.copyWith(
                                color: context.color.onPrimaryContainer.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: context.color.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.color.outlineVariant, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: context.color.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Нет платежей на этот день',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.color.onSurfaceVariant,
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
