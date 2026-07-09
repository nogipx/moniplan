import 'package:flutter_test/flutter_test.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/goals/models/savings_goal.dart';
import 'package:moniplan_app/features/goals/usecases/compute_daily_allowance_usecase.dart';
import 'package:moniplan_app/features/planner/usecases/_index.dart';

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

SavingsGoal _goal({num amount = 0, int days = 0}) => SavingsGoal(
      id: 'pl',
      plannerId: 'pl',
      type: SavingsGoalType.perPeriod,
      basis: days > 0 ? GoalBasis.days : GoalBasis.amount,
      amount: amount,
      days: days,
    );

void main() {
  // 250000 start; -30000 on 10, -60000 on 15; +100000 salary on 20.
  final payments = [
    _p(date: DateTime(2026, 3, 10), money: 30000, type: PaymentType.expense),
    _p(date: DateTime(2026, 3, 15), money: 60000, type: PaymentType.expense),
    _p(date: DateTime(2026, 3, 20), money: 100000, type: PaymentType.income),
  ];
  final series = BuildBalanceSeriesUseCase(
    payments: payments,
    initialBalance: 250000,
    dateStart: DateTime(2026, 3, 1),
    dateEnd: DateTime(2026, 3, 31),
  ).call();

  DailyAllowance run(SavingsGoal goal, DateTime today) =>
      ComputeDailyAllowanceUseCase(
        series: series,
        payments: payments,
        today: today,
        goal: goal,
      ).call()!;

  test('daily allowance to keep X until next salary', () {
    final a = run(_goal(amount: 40000), DateTime(2026, 3, 5));
    expect(a.hasNextSalary, isTrue);
    expect(a.nextSalaryDate, DateTime(2026, 3, 20));
    expect(a.daysUntilSalary, 15);
    expect(a.todayBalance, 250000);
    expect(a.scheduledOutflows, 90000); // 30000 + 60000 ahead
    expect(a.target, 40000);
    expect(a.bindingBalance, 160000);
    expect(a.bindingBeyondSalary, isFalse); // trough is before the salary here
    expect(a.free, 120000);
    expect(a.perDay, 8000); // 120000 / 15
    expect(a.overspent, isFalse);
  });

  test('overspend when target is too high', () {
    final a = run(_goal(amount: 200000), DateTime(2026, 3, 5));
    expect(a.free, -40000);
    expect(a.overspent, isTrue);
    expect(a.perDay, lessThan(0));
  });

  test('today expenses already in balance are not double-counted', () {
    // today = 10, the 30000 bill lands today -> already in todayBalance 220000,
    // only the 60000 on 15 is ahead.
    final a = run(_goal(amount: 40000), DateTime(2026, 3, 10));
    expect(a.todayBalance, 220000);
    expect(a.scheduledOutflows, 60000);
    expect(a.daysUntilSalary, 10); // 10 -> 20
    expect(a.bindingBalance, 160000);
    expect(a.free, 120000);
    expect(a.perDay, 12000);
  });

  test('a big expense AFTER the next salary tightens the limit', () {
    // Add a huge bill after the salary: balance dips deeper post-salary than
    // the pre-salary trough, so it must bind the limit now.
    final withBigBill = [
      ...payments, // -30000@10, -60000@15, +100000@20
      _p(date: DateTime(2026, 3, 25), money: 230000, type: PaymentType.expense),
    ];
    final s = BuildBalanceSeriesUseCase(
      payments: withBigBill,
      initialBalance: 250000,
      dateStart: DateTime(2026, 3, 1),
      dateEnd: DateTime(2026, 3, 31),
    ).call();
    final a = ComputeDailyAllowanceUseCase(
      series: s,
      payments: withBigBill,
      today: DateTime(2026, 3, 5),
      goal: _goal(amount: 40000),
    ).call()!;

    // Post-salary: 260000 - 230000 = 30000 on the 25th — the global min.
    expect(a.bindingBalance, 30000);
    expect(a.bindingDate, DateTime(2026, 3, 25));
    expect(a.bindingBeyondSalary, isTrue);
    expect(a.free, -10000); // 30000 - 40000: can't keep X, overspend
    expect(a.overspent, isTrue);
  });
}
