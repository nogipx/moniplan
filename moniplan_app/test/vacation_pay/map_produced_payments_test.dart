import 'package:flutter_test/flutter_test.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/vacation_pay/mappers/map_produced_payments_use_case.dart';
import 'package:moniplan_payroll/moniplan_payroll.dart';

void main() {
  // Case 7 (spec 8.7) — mapping idempotency: normalizedMoney of an imported
  // payment equals net (tax = 0 must not cut the NDFL a second time).
  test('7. normalizedMoney of a mapped payment equals net', () {
    final engine = PayrollEngine(clock: () => DateTime(2026, 1, 1));
    final result = engine.compute(PayrollRequest.vacation(
      profile: const IncomeProfile(
        id: 'p1',
        title: 'Main',
        grossMonthly: 370000,
        ytdGrossAtYearStart: 2220000,
      ),
      vacationStart: DateTime(2026, 7, 13),
      vacationEnd: DateTime(2026, 7, 19),
      mode: CalcMode.quick,
    ));

    final payments = MapProducedPaymentsUseCase(
      result: result,
      sessionId: 'sess-1',
    ).call();

    expect(payments.length, result.payments.length);

    for (var i = 0; i < payments.length; i++) {
      final mapped = payments[i];
      final produced = result.payments[i];

      // The load-bearing invariant.
      expect(mapped.normalizedMoney, closeTo(produced.net, 0.001),
          reason: '${produced.kind}');

      expect(mapped.details.type, PaymentType.income);
      expect(mapped.details.tax, 0);
      expect(mapped.details.money, produced.net);
      expect(mapped.repeat, DateTimeRepeat.noRepeat);
      expect(mapped.isEnabled, isTrue);
      expect(mapped.isDone, isFalse);
      expect(mapped.details.tags, contains('import:vacation:sess-1'));
      expect(mapped.paymentId, isNotEmpty);
    }
  });

  test('names and note are human-readable', () {
    final engine = PayrollEngine(clock: () => DateTime(2026, 1, 1));
    final result = engine.compute(PayrollRequest.vacation(
      profile: const IncomeProfile(
        id: 'p1',
        title: 'Main',
        grossMonthly: 370000,
      ),
      vacationStart: DateTime(2026, 7, 13),
      vacationEnd: DateTime(2026, 7, 19),
      mode: CalcMode.quick,
    ));

    final payments = MapProducedPaymentsUseCase(
      result: result,
      sessionId: 'sess-2',
    ).call();

    final vac = payments.firstWhere(
      (p) => p.details.name.startsWith('Отпускные'),
    );
    expect(vac.details.name, 'Отпускные 13–19 июля');
    expect(vac.details.note, contains('Гросс'));
    expect(vac.details.note, contains('НДФЛ'));
  });
}
