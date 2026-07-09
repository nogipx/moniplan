import 'package:flutter_test/flutter_test.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/planner/usecases/_index.dart';
import 'package:moniplan_app/features/savings/usecases/compute_savings_usecase.dart';

Payment _p({
  required DateTime date,
  required num money,
  required PaymentType type,
}) =>
    Payment(
      paymentId: '${type.name}-${date.day}-$money',
      date: date,
      details: PaymentDetails(
        name: 't',
        type: type,
        currency: CurrencyDataCommon.rub,
        money: money,
      ),
    );

void main() {
  // 100000 start; savings -20000 on 10; expense -5000 on 12; withdraw +8000 on 20.
  final payments = [
    _p(date: DateTime(2026, 3, 10), money: 20000, type: PaymentType.savings),
    _p(date: DateTime(2026, 3, 12), money: 5000, type: PaymentType.expense),
    _p(
        date: DateTime(2026, 3, 20),
        money: 8000,
        type: PaymentType.savingsWithdraw),
  ];
  final series = BuildBalanceSeriesUseCase(
    payments: payments,
    initialBalance: 100000,
    dateStart: DateTime(2026, 3, 1),
    dateEnd: DateTime(2026, 3, 31),
  ).call();

  BalancePoint on(int day) => series.firstWhere((p) => p.date.day == day);

  test('savings moves the balance but is not counted as expense', () {
    expect(on(10).balance, 80000); // deposit reduced balance
    expect(on(10).outcome, 0); // ...but not as an expense
    expect(on(12).outcome, -5000); // real expense still counts
    expect(on(20).balance, 83000); // withdraw returned money
  });

  test('projected includes all future planned savings (recurring)', () {
    // As a monthly savings would expand into: past + two future occurrences.
    final recurring = [
      _p(date: DateTime(2026, 3, 10), money: 5000, type: PaymentType.savings),
      _p(date: DateTime(2026, 4, 10), money: 5000, type: PaymentType.savings),
      _p(date: DateTime(2026, 5, 10), money: 5000, type: PaymentType.savings),
    ];
    final s = ComputeSavingsUseCase(
      payments: recurring,
      today: DateTime(2026, 3, 15),
    ).call();
    expect(s.today, 5000); // only March occurrence has happened
    expect(s.projected, 15000); // all three, incl. future recurring
  });

  test('accumulated today and projected', () {
    final s = ComputeSavingsUseCase(
      payments: payments,
      today: DateTime(2026, 3, 15),
    ).call();
    expect(s.today, 20000); // deposit counted, withdraw (20th) not yet
    expect(s.projected, 12000); // forecast to plan end: 20000 - 8000
    expect(s.deposits, 20000); // factual to today
    expect(s.withdrawals, 0); // withdraw on 20th is still future
  });
}
