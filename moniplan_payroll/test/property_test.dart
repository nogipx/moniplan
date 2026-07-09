import 'dart:math' as math;

import 'package:moniplan_payroll/moniplan_payroll.dart';
import 'package:test/test.dart';

PayrollEngine _engine() => PayrollEngine(clock: () => DateTime(2026, 1, 1));

void main() {
  // Case 19 (spec 8.19) — monotonicity: raising the base never lowers avgDaily.
  test('19. avgDaily is monotonic in grossMonthly', () {
    num? prevAvg;
    for (var gross = 20000; gross <= 6000000; gross += 137000) {
      final r = _engine().compute(PayrollRequest.vacation(
        profile: IncomeProfile(id: 'p', title: 't', grossMonthly: gross),
        vacationStart: DateTime(2026, 7, 13),
        vacationEnd: DateTime(2026, 7, 19),
        mode: CalcMode.quick,
      ));
      final avg = r.breakdown.avgDailyEarnings;
      if (prevAvg != null) {
        expect(avg, greaterThanOrEqualTo(prevAvg));
      }
      prevAvg = avg;
    }
  });

  // Case 20 (spec 8.20) — sum(net) + sum(ndfl) == sum(gross) on random inputs.
  test('20. money invariant holds on random inputs', () {
    final rnd = math.Random(20260709);
    for (var i = 0; i < 500; i++) {
      final gross = 30000 + rnd.nextInt(6000000);
      final ytd = rnd.nextInt(50000000).toDouble();
      final startDay = 1 + rnd.nextInt(20);
      final month = 1 + rnd.nextInt(12);
      final len = rnd.nextInt(20);
      final start = DateTime(2026, month, startDay);
      final end = start.add(Duration(days: len));

      final r = _engine().compute(PayrollRequest.vacation(
        profile: IncomeProfile(
          id: 'p',
          title: 't',
          grossMonthly: gross,
          ytdGrossAtYearStart: ytd,
        ),
        vacationStart: start,
        vacationEnd: end,
        mode: CalcMode.quick,
      ));

      final g = r.payments.fold<num>(0, (s, p) => s + p.gross);
      final n = r.payments.fold<num>(0, (s, p) => s + p.net);
      final t = r.payments.fold<num>(0, (s, p) => s + p.ndfl);
      expect(n + t, closeTo(g, 0.001), reason: 'i=$i gross=$gross ytd=$ytd');
    }
  });
}
