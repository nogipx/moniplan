import 'package:moniplan_payroll/moniplan_payroll.dart';
import 'package:test/test.dart';

/// Clock fixed before the reference vacation so late-payment warnings don't
/// fire in golden cases.
PayrollEngine _engine() => PayrollEngine(clock: () => DateTime(2026, 1, 1));

IncomeProfile _profile({
  num grossMonthly = 370000,
  num ytd = 0,
  PaySchedule schedule = const PaySchedule(),
}) =>
    IncomeProfile(
      id: 'p1',
      title: 'Main',
      grossMonthly: grossMonthly,
      ytdGrossAtYearStart: ytd,
      paySchedule: schedule,
    );

ProducedPayment _byKind(PayrollResult r, ProducedPaymentKind kind) =>
    r.payments.firstWhere((p) => p.kind == kind);

Iterable<ProducedPayment> _allOfKind(PayrollResult r, ProducedPaymentKind kind) =>
    r.payments.where((p) => p.kind == kind);

void main() {
  group('quick mode — vacation', () {
    // Case 1 (spec 8.1) — reference.
    //
    // NOTE: constants below are engine-derived and internally consistent
    // (verified by hand). They still need a final reconciliation to the real
    // July payslip to satisfy acceptance criterion 9 "to the kopeck".
    test('1. reference: 370k gross, 13-19.07.2026, YTD 2.22M, 13/15 crossing',
        () {
      final r = _engine().compute(PayrollRequest.vacation(
        profile: _profile(ytd: 2220000),
        vacationStart: DateTime(2026, 7, 13),
        vacationEnd: DateTime(2026, 7, 19),
        mode: CalcMode.quick,
      ));

      expect(r.breakdown.payableVacationDays, 7);

      final vac = _byKind(r, ProducedPaymentKind.vacationPay);
      expect(vac.date, DateTime(2026, 7, 10)); // start - 3 days
      expect(vac.gross, closeTo(88395.90, 0.001));
      expect(vac.ndfl, 11491);
      expect(vac.net, closeTo(76904.90, 0.001));
      expect(vac.marginalRate, 0.13);

      final first = _byKind(r, ProducedPaymentKind.firstHalfSalary);
      expect(first.date, DateTime(2026, 7, 20));
      expect(first.gross, closeTo(128695.65, 0.001));
      expect(first.ndfl, 17473);
      expect(first.net, closeTo(111222.65, 0.001));
      // Threshold 2.4M crossed inside this payment: mixed 13/15, last ruble 15%.
      expect(first.marginalRate, 0.15);

      final second = _byKind(r, ProducedPaymentKind.secondHalfSalary);
      expect(second.date, DateTime(2026, 8, 5));
      expect(second.gross, closeTo(160869.57, 0.001));
      expect(second.ndfl, 24130);
      expect(second.net, closeTo(136739.57, 0.001));
      expect(second.marginalRate, 0.15);

      _expectInvariant(r);
    });

    // Case 2 (spec 8.2) — YTD 0, everything at 13%.
    test('2. YTD = 0 keeps every payment at 13%', () {
      final r = _engine().compute(PayrollRequest.vacation(
        profile: _profile(ytd: 0),
        vacationStart: DateTime(2026, 7, 13),
        vacationEnd: DateTime(2026, 7, 19),
        mode: CalcMode.quick,
      ));

      for (final p in r.payments) {
        expect(p.marginalRate, 0.13, reason: '${p.kind}');
      }
      final totalNdfl = r.payments.fold<num>(0, (s, p) => s + p.ndfl);
      // roundRuble(377961.12 * 0.13) == 49135.
      expect(totalNdfl, 49135);
      _expectInvariant(r);
    });

    // Case 3 (spec 8.3) — public holiday inside the vacation range.
    test('3. holiday (12.06) is not paid: 8-14.06 -> 6 payable days', () {
      final r = _engine().compute(PayrollRequest.vacation(
        profile: _profile(),
        vacationStart: DateTime(2026, 6, 8),
        vacationEnd: DateTime(2026, 6, 14),
        mode: CalcMode.quick,
      ));

      expect(r.breakdown.payableVacationDays, 6);
      final vac = _byKind(r, ProducedPaymentKind.vacationPay);
      expect(vac.date, DateTime(2026, 6, 5));
      // 370000/29.3 * 6.
      expect(vac.gross, closeTo(75767.92, 0.001));
      _expectInvariant(r);
    });

    // Case 4 (spec 8.4) — vacation across a month boundary.
    test('4. crossing month boundary produces both months salary', () {
      final r = _engine().compute(PayrollRequest.vacation(
        profile: _profile(),
        vacationStart: DateTime(2026, 6, 29),
        vacationEnd: DateTime(2026, 7, 3),
        mode: CalcMode.quick,
      ));

      expect(r.breakdown.payableVacationDays, 5);
      expect(_allOfKind(r, ProducedPaymentKind.firstHalfSalary).length, 2);
      expect(_allOfKind(r, ProducedPaymentKind.secondHalfSalary).length, 2);

      // June second half is reduced: 11 working days in 16-30, minus 29 & 30
      // in the vacation = 9 worked, over 21 working days in June.
      final juneSecond = _allOfKind(r, ProducedPaymentKind.secondHalfSalary)
          .firstWhere((p) => p.date.month == 7); // payday 5 Jul -> Fri 3 Jul
      expect(juneSecond.gross, closeTo(370000 * 9 / 21, 0.01));
      _expectInvariant(r);
    });

    // Case 5 (spec 8.5) — payday on a weekend shifts to the previous work day.
    test('5. payday on Saturday shifts back: Sep 5 (Sat) -> Sep 4 (Fri)', () {
      final r = _engine().compute(PayrollRequest.vacation(
        profile: _profile(),
        vacationStart: DateTime(2026, 8, 10),
        vacationEnd: DateTime(2026, 8, 16),
        mode: CalcMode.quick,
      ));

      final augSecond = _byKind(r, ProducedPaymentKind.secondHalfSalary);
      // Nominal payday 5 Sep is Saturday.
      expect(DateTime(2026, 9, 5).weekday, DateTime.saturday);
      expect(augSecond.date, DateTime(2026, 9, 4));
      _expectInvariant(r);
    });

    // Case 6 (spec 8.6) — vacation entirely on the weekend.
    test('6. Sat-Sun vacation: 2 paid days, month salary unchanged', () {
      final r = _engine().compute(PayrollRequest.vacation(
        profile: _profile(),
        vacationStart: DateTime(2026, 7, 18), // Saturday
        vacationEnd: DateTime(2026, 7, 19), // Sunday
        mode: CalcMode.quick,
      ));

      expect(r.breakdown.payableVacationDays, 2);
      final salary = _allOfKind(r, ProducedPaymentKind.firstHalfSalary)
              .fold<num>(0, (s, p) => s + p.gross) +
          _allOfKind(r, ProducedPaymentKind.secondHalfSalary)
              .fold<num>(0, (s, p) => s + p.gross);
      // No working days removed -> full month salary.
      expect(salary, closeTo(370000, 0.01));
      _expectInvariant(r);
    });
  });

  group('validation', () {
    test('vacationEnd before start throws typed error', () {
      expect(
        () => _engine().compute(PayrollRequest.vacation(
          profile: _profile(),
          vacationStart: DateTime(2026, 7, 19),
          vacationEnd: DateTime(2026, 7, 13),
          mode: CalcMode.quick,
        )),
        throwsA(isA<PayrollInputError>()),
      );
    });

    test('non-positive gross throws typed error', () {
      expect(
        () => _engine().compute(PayrollRequest.vacation(
          profile: _profile(grossMonthly: 0),
          vacationStart: DateTime(2026, 7, 13),
          vacationEnd: DateTime(2026, 7, 19),
          mode: CalcMode.quick,
        )),
        throwsA(isA<PayrollInputError>()),
      );
    });

    test('precise mode not yet implemented', () {
      expect(
        () => _engine().compute(PayrollRequest.vacation(
          profile: _profile(),
          vacationStart: DateTime(2026, 7, 13),
          vacationEnd: DateTime(2026, 7, 19),
          mode: CalcMode.precise,
        )),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('quick mode — dismissal compensation', () {
    // Case 16 (spec 8.16) — quick variant: days * avgDaily.
    test('14.33 unused days * avg daily', () {
      final r = _engine().compute(PayrollRequest.dismissalCompensation(
        profile: _profile(),
        dismissalDate: DateTime(2026, 7, 15),
        unusedVacationDays: 14.33,
        mode: CalcMode.quick,
      ));

      final comp = _byKind(r, ProducedPaymentKind.dismissalCompensation);
      expect(comp.date, DateTime(2026, 7, 15));
      expect(comp.gross, closeTo(370000 / 29.3 * 14.33, 0.01));
      _expectInvariant(r);
    });
  });
}

/// Spec 5.5 invariant: sum(net) + sum(ndfl) == sum(gross).
void _expectInvariant(PayrollResult r) {
  final g = r.payments.fold<num>(0, (s, p) => s + p.gross);
  final n = r.payments.fold<num>(0, (s, p) => s + p.net);
  final t = r.payments.fold<num>(0, (s, p) => s + p.ndfl);
  expect(n + t, closeTo(g, 0.001));
}
