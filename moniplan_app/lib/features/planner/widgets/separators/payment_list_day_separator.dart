// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListDaySeparator extends StatelessWidget {
  final DateTime date;
  final DateTime today;

  const PaymentListDaySeparator({
    required this.date,
    required this.today,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSameDay = today.isSameDay(date);

    return AppContourAnimation(
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
              padding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 8,
              ),
              child: Text(
                DateFormat.MMMMd().format(date),
                style: context.text.labelMedium?.copyWith(
                  color: isSameDay ? context.color.onInverseSurface : context.color.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
