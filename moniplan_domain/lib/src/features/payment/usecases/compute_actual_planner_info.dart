// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: prefer_collection_literals

import 'package:moniplan_domain/moniplan_domain.dart';

class ComputeActualPlannerInfo implements IUseCase<PlannerActualInfo> {
  final String plannerId;
  final num lastUpdatedBudget;
  final Iterable<Payment> payments;

  const ComputeActualPlannerInfo({
    required this.payments,
    this.plannerId = '',
    this.lastUpdatedBudget = 0,
  });

  @override
  PlannerActualInfo run() {
    final now = DateTime.now();
    final counts = {
      'completed': 0,
      'waiting': 0,
      'disabled': 0,
      'total': 0,
    };

    for (final payment in payments) {
      if (payment.isEnabled) {
        if (payment.isDone) {
          counts.update('completed', (a) => a + 1);
        } else {
          counts.update('waiting', (a) => a + 1);
        }
      } else {
        counts.update('disabled', (a) => a + 1);
      }
      counts.update('total', (a) => a + 1);
    }

    final info = PlannerActualInfo(
      plannerId: plannerId,
      updatedAtBudget: lastUpdatedBudget,
      updatedAt: now,
      completedCount: counts['completed']!,
      waitingCount: counts['waiting']!,
      disabledCount: counts['disabled']!,
      totalCount: counts['total']!,
    );

    return info;
  }
}
