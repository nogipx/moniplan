import 'package:flutter_test/flutter_test.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/planner/usecases/_index.dart';

Payment _p({
  required DateTime date,
  required num money,
  required PaymentType type,
}) {
  return Payment(
    paymentId: '${type.name}-${date.toIso8601String()}-$money',
    date: date,
    details: PaymentDetails(
      name: 't',
      type: type,
      currency: CurrencyDataCommon.rub,
      money: money,
    ),
  );
}

void main() {
  // Window 01-31 Mar 2026, start 20000.
  // -5000 on 05 -> 15000; correction=100000 on 10 -> reset to 100000;
  // -8000 on 20 -> 92000.
  final payments = [
    _p(date: DateTime(2026, 3, 5), money: 5000, type: PaymentType.expense),
    _p(date: DateTime(2026, 3, 10), money: 100000, type: PaymentType.correction),
    _p(date: DateTime(2026, 3, 20), money: 8000, type: PaymentType.expense),
  ];

  List<BalancePoint> series() => BuildBalanceSeriesUseCase(
        payments: payments,
        initialBalance: 20000,
        dateStart: DateTime(2026, 3, 1),
        dateEnd: DateTime(2026, 3, 31),
      ).call();

  num balanceOn(List<BalancePoint> s, DateTime d) =>
      s.firstWhere((p) => p.date.year == d.year &&
          p.date.month == d.month &&
          p.date.day == d.day).balance;

  test('correction resets the balance curve to its value', () {
    final s = series();
    expect(balanceOn(s, DateTime(2026, 3, 9)), 15000);
    expect(balanceOn(s, DateTime(2026, 3, 10)), 100000); // set, not added
    expect(balanceOn(s, DateTime(2026, 3, 31)), 92000);
  });

  test('a correction divides the plan into periods', () {
    final periods = SplitPeriodsByCorrectionUseCase(
      series: series(),
      payments: payments,
    ).call();

    expect(periods.length, 2);

    final before = periods[0];
    expect(before.startedByCorrection, isFalse);
    expect(before.startBalance, 20000);
    expect(before.netChange, -5000);

    final after = periods[1];
    expect(after.startedByCorrection, isTrue);
    expect(after.start, DateTime(2026, 3, 10));
    expect(after.startBalance, 100000);
    expect(after.netChange, -8000);
    expect(after.lowestBalance, 92000);
  });
}
