import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/planner/usecases/sort_payments_usecase.dart';
import 'package:moniplan_app/utils/_index.dart';

/// Одна точка ежедневной кривой баланса материализованного планера.
class BalancePoint {
  BalancePoint({
    required this.date,
    required this.balance,
    this.delta = 0,
    this.income = 0,
    this.outcome = 0,
  });

  final DateTime date;
  final num balance;
  final num delta;

  /// Доход за день (положительный).
  final num income;

  /// Расход за день (знаковый, отрицательный).
  final num outcome;
}

/// Строит ежедневную кривую баланса по уже материализованным платежам
/// планера до конца периода. Чистая функция — не влияет на генерацию планера.
class BuildBalanceSeriesUseCase {
  const BuildBalanceSeriesUseCase({
    required this.payments,
    required this.initialBalance,
    required this.dateStart,
    required this.dateEnd,
  });

  final List<Payment> payments;
  final num initialBalance;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  List<BalancePoint> call() {
    final enabled = payments.where((p) => p.isEnabled).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final start =
        dateStart ?? (enabled.isNotEmpty ? enabled.first.date : DateTime.now());
    final end = dateEnd ??
        (enabled.isNotEmpty
            ? enabled.last.date
            : start.add(const Duration(days: 7)));

    final byDay = <DateTime, List<Payment>>{};
    for (final p in enabled) {
      byDay.putIfAbsent(p.date.dayBound, () => []).add(p);
    }

    final points = <BalancePoint>[];
    var balance = initialBalance;
    var cursor = start.dayBound;
    final last = end.dayBound;
    while (!cursor.isAfter(last)) {
      final dayPayments = byDay[cursor] ?? const <Payment>[];
      final startBalance = balance;
      num income = 0;
      num outcome = 0;
      // Same order as ComputeBudgetUseCase: corrections come last and set the
      // running balance to their absolute value.
      for (final p in SortPaymentsUsecase(payments: dayPayments).run()) {
        if (p.type == PaymentType.correction) {
          balance = p.details.money;
          continue;
        }
        final value = p.normalizedMoney;
        balance += value;
        if (p.type == PaymentType.income) {
          income += value;
        } else if (p.type == PaymentType.expense) {
          outcome += value;
        }
      }
      points.add(BalancePoint(
        date: cursor,
        balance: balance,
        delta: balance - startBalance,
        income: income,
        outcome: outcome,
      ));
      cursor = cursor.add(const Duration(days: 1));
    }

    if (points.length == 1) {
      points.add(BalancePoint(
        date: points.first.date.add(const Duration(days: 1)),
        balance: balance,
      ));
    }

    return points;
  }
}
