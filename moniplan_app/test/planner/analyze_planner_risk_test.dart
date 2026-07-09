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
  group('AnalyzePlannerRiskUseCase', () {
    // Window 01-31 Mar 2026, start balance 20000.
    // expenses: -5000 on 05, -5000 on 10 (before income), -8000 on 25.
    // income: +30000 on 20.
    // Balance dips to 10000 (05..19), jumps to 40000 on 20, down to 32000 on 25.
    final payments = [
      _p(date: DateTime(2026, 3, 5), money: 5000, type: PaymentType.expense),
      _p(date: DateTime(2026, 3, 10), money: 5000, type: PaymentType.expense),
      _p(date: DateTime(2026, 3, 20), money: 30000, type: PaymentType.income),
      _p(date: DateTime(2026, 3, 25), money: 8000, type: PaymentType.expense),
    ];

    List<BalancePoint> buildSeries() => BuildBalanceSeriesUseCase(
          payments: payments,
          initialBalance: 20000,
          dateStart: DateTime(2026, 3, 1),
          dateEnd: DateTime(2026, 3, 31),
        ).call();

    test('trough is the pre-income low, no shortfall', () {
      final risk = AnalyzePlannerRiskUseCase(
        series: buildSeries(),
        payments: payments,
        today: DateTime(2026, 3, 1),
      ).call();

      expect(risk, isNotNull);
      expect(risk!.lowestBalance, 10000);
      expect(risk.lowestBalanceDate, DateTime(2026, 3, 10));
      expect(risk.hasShortfall, isFalse);
      expect(risk.shortfallDate, isNull);
      expect(risk.bufferDays, isNotNull);
    });

    test('longest income-free gap is start..first income', () {
      final risk = AnalyzePlannerRiskUseCase(
        series: buildSeries(),
        payments: payments,
        today: DateTime(2026, 3, 1),
      ).call();

      final gap = risk!.longestGap!;
      // 01 Mar -> 20 Mar = 19 days, spend 10000, low 10000.
      expect(gap.start, DateTime(2026, 3, 1));
      expect(gap.end, DateTime(2026, 3, 20));
      expect(gap.days, 19);
      expect(gap.spend, 10000);
      expect(gap.lowestBalance, 10000);
    });

    test('shortfall is detected when balance goes negative', () {
      final broke = [
        _p(date: DateTime(2026, 3, 5), money: 25000, type: PaymentType.expense),
      ];
      final series = BuildBalanceSeriesUseCase(
        payments: broke,
        initialBalance: 20000,
        dateStart: DateTime(2026, 3, 1),
        dateEnd: DateTime(2026, 3, 31),
      ).call();
      final risk = AnalyzePlannerRiskUseCase(
        series: series,
        payments: broke,
        today: DateTime(2026, 3, 1),
      ).call();

      expect(risk!.hasShortfall, isTrue);
      expect(risk.shortfallDate, DateTime(2026, 3, 5));
      expect(risk.lowestBalance, -5000);
      expect(risk.bufferDays, isNull); // no buffer when underwater
    });
  });
}
