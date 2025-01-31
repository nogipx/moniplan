// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

class GroupPaymentsByDateUsecase implements IUseCase<List<PaymentsDateGrouped>> {
  final List<Payment> payments;
  final DateTime? today;

  const GroupPaymentsByDateUsecase({
    required this.payments,
    this.today,
  });

  @override
  List<PaymentsDateGrouped> run() {
    final mapped = <DateTime, List<Payment>>{};

    for (final payment in payments) {
      mapped.putIfAbsent(payment.date.dayBound, () => []).add(payment);
    }

    final effectiveToday = today?.dayBound;
    if (effectiveToday != null && !mapped.containsKey(effectiveToday)) {
      mapped[effectiveToday] = [];
    }

    final entries = mapped.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    final result = entries.map((e) {
      return PaymentsDateGrouped(
        date: e.key,
        payments: e.value,
      );
    }).toList();

    return result;
  }
}
