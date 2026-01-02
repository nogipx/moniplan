import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/utils/_index.dart';

import '_index.dart';

class GroupPaymentsByDateUsecase {
  final List<Payment> payments;
  final DateTime? today;

  const GroupPaymentsByDateUsecase({required this.payments, this.today});

  List<PaymentsDateGrouped> run() {
    final mapped = <DateTime, List<Payment>>{};

    for (final payment in payments) {
      mapped.putIfAbsent(payment.date.dayBound, () => []).add(payment);
    }

    final effectiveToday = today?.dayBound;
    if (effectiveToday != null && !mapped.containsKey(effectiveToday)) {
      mapped[effectiveToday] = [];
    }

    final entries = mapped.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    final result =
        entries.map((e) {
          // Используем юзкейс для сортировки платежей в рамках дня
          final sortedPayments = SortPaymentsUsecase(payments: e.value).run();
          return PaymentsDateGrouped(date: e.key, payments: sortedPayments);
        }).toList();

    return result;
  }
}
