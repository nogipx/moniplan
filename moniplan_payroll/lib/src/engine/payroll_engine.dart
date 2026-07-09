import 'dart:math' as math;

import '../models/enums.dart';
import '../models/errors.dart';
import '../models/income_profile.dart';
import '../models/payroll_request.dart';
import '../models/payroll_result.dart';
import '../reference/mrot_history.dart';
import '../reference/ndfl_scale.dart';
import '../reference/production_calendar.dart';
import 'money.dart';

/// The payroll engine (spec 5). Pure function: request -> result.
///
/// Step 1 implements quick mode (avgDaily = grossMonthly / 29.3). Precise mode
/// is wired but not yet implemented.
class PayrollEngine {
  PayrollEngine({
    ProductionCalendar? calendar,
    NdflScaleRegistry? ndfl,
    MrotHistory? mrot,
    DateTime Function()? clock,
  })  : calendar = calendar ?? ProductionCalendar.ru(),
        ndfl = ndfl ?? NdflScaleRegistry.ru(),
        mrot = mrot ?? MrotHistory.ru(),
        _clock = clock ?? DateTime.now;

  final ProductionCalendar calendar;
  final NdflScaleRegistry ndfl;
  final MrotHistory mrot;
  final DateTime Function() _clock;

  PayrollResult compute(PayrollRequest request) {
    _validate(request);
    if (request.mode == CalcMode.precise) {
      throw UnimplementedError('Precise mode arrives in step 2.');
    }
    return switch (request) {
      VacationRequest() => _computeVacation(request),
      DismissalRequest() => _computeDismissal(request),
    };
  }

  // --- validation (spec 6) ------------------------------------------------

  void _validate(PayrollRequest request) {
    if (request.profile.grossMonthly <= 0) {
      throw const PayrollInputError(
        'nonPositiveGross',
        'grossMonthly must be positive',
      );
    }
    switch (request) {
      case VacationRequest(:final vacationStart, :final vacationEnd):
        if (vacationEnd.isBefore(vacationStart)) {
          throw const PayrollInputError(
            'vacationEndBeforeStart',
            'vacationEnd is before vacationStart',
          );
        }
      case DismissalRequest(:final unusedVacationDays):
        if (unusedVacationDays <= 0) {
          throw const PayrollInputError(
            'nonPositiveDays',
            'unusedVacationDays must be positive',
          );
        }
    }
  }

  // --- vacation (spec 5.2, 5.3) ------------------------------------------

  PayrollResult _computeVacation(VacationRequest req) {
    final profile = req.profile;
    final warnings = <PayrollWarning>[];

    final avg = _quickAvgDaily(profile, req.vacationStart, warnings);

    final start = _dateOnly(req.vacationStart);
    final end = _dateOnly(req.vacationEnd);
    final calDays = end.difference(start).inDays + 1;
    final holidays = calendar.publicHolidaysBetween(start, end);
    final payableDays = calDays - holidays;

    final vacationGross =
        roundKopeck(avg.value * payableDays + req.manualAdjustment);
    final vacationDate = start.subtract(const Duration(days: 3));

    if (vacationDate.isBefore(_dateOnly(_clock()))) {
      warnings.add(const PayrollWarning(
        kind: PayrollWarningKind.latePaymentDeadlineMissed,
        message: 'Vacation-pay deadline (3 days before start) already passed.',
      ));
    }

    final pre = <_Pre>[
      _Pre(
        ProducedPaymentKind.vacationPay,
        vacationDate,
        vacationGross,
        periodStart: start,
        periodEnd: end,
      ),
    ];
    pre.addAll(_salaryPayments(profile, start, end));

    final payments = _applyNdfl(profile, req.vacationStart.year, pre);

    final breakdown = PayrollBreakdown(
      avgDailyEarnings: avg.value,
      payableVacationDays: payableDays,
      mrotFloorApplied: avg.mrotFloorApplied,
      warnings: warnings,
    );
    return PayrollResult(payments: payments, breakdown: breakdown);
  }

  /// Reduced salary payments for every month the vacation touches (spec 5.3.3).
  List<_Pre> _salaryPayments(IncomeProfile profile, DateTime start, DateTime end) {
    final result = <_Pre>[];
    for (final ym in _touchedMonths(start, end)) {
      final n = calendar.workingDaysInMonth(ym.year, ym.month);
      if (n == 0) continue;

      final firstStart = DateTime(ym.year, ym.month, 1);
      final firstEnd = DateTime(ym.year, ym.month, 15);
      final secondStart = DateTime(ym.year, ym.month, 16);
      final secondEnd = DateTime(ym.year, ym.month + 1, 0);

      final firstWork = calendar.workingDaysBetween(firstStart, firstEnd);
      final secondWork = calendar.workingDaysBetween(secondStart, secondEnd);
      final vacFirst = _vacationWorkingDaysWithin(start, end, firstStart, firstEnd);
      final vacSecond =
          _vacationWorkingDaysWithin(start, end, secondStart, secondEnd);

      final workedFirst = firstWork - vacFirst;
      final workedSecond = secondWork - vacSecond;

      final grossFirst = roundKopeck(profile.grossMonthly * workedFirst / n);
      final grossSecond = roundKopeck(profile.grossMonthly * workedSecond / n);

      final firstPayday = _payday(ym.year, ym.month, profile.paySchedule.firstHalfDay);
      final nextMonthFirst = DateTime(ym.year, ym.month + 1, 1);
      final secondPayday = _payday(
        nextMonthFirst.year,
        nextMonthFirst.month,
        profile.paySchedule.secondHalfDay,
      );

      if (grossFirst > 0) {
        result.add(_Pre(
          ProducedPaymentKind.firstHalfSalary,
          firstPayday,
          grossFirst,
          periodStart: firstStart,
          periodEnd: firstEnd,
        ));
      }
      if (grossSecond > 0) {
        result.add(_Pre(
          ProducedPaymentKind.secondHalfSalary,
          secondPayday,
          grossSecond,
          periodStart: secondStart,
          periodEnd: secondEnd,
        ));
      }
    }
    return result;
  }

  // --- dismissal (spec 5.3.4) --------------------------------------------

  PayrollResult _computeDismissal(DismissalRequest req) {
    final profile = req.profile;
    final warnings = <PayrollWarning>[];
    final avg = _quickAvgDaily(profile, req.dismissalDate, warnings);

    final gross = roundKopeck(avg.value * req.unusedVacationDays);
    final date = _dateOnly(req.dismissalDate);
    final payments = _applyNdfl(profile, req.dismissalDate.year, [
      _Pre(ProducedPaymentKind.dismissalCompensation, date, gross),
    ]);

    final breakdown = PayrollBreakdown(
      avgDailyEarnings: avg.value,
      payableVacationDays: req.unusedVacationDays,
      mrotFloorApplied: avg.mrotFloorApplied,
      warnings: warnings,
    );
    return PayrollResult(payments: payments, breakdown: breakdown);
  }

  // --- average daily earnings (quick) ------------------------------------

  _AvgDaily _quickAvgDaily(
    IncomeProfile profile,
    DateTime eventDate,
    List<PayrollWarning> warnings,
  ) {
    var value = profile.grossMonthly / kAvgMonthDays;
    final floor = mrot.valueAt(eventDate) / kAvgMonthDays;
    var mrotFloorApplied = false;
    if (value < floor) {
      value = floor;
      mrotFloorApplied = true;
      warnings.add(const PayrollWarning(
        kind: PayrollWarningKind.mrotFloorApplied,
        message: 'Average daily earnings raised to the MROT floor.',
      ));
    }
    return _AvgDaily(value, mrotFloorApplied);
  }

  // --- NDFL (spec 5.4) ----------------------------------------------------

  List<ProducedPayment> _applyNdfl(
    IncomeProfile profile,
    int primaryYear,
    List<_Pre> pre,
  ) {
    pre.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      return a.kind.index.compareTo(b.kind.index);
    });

    final byYear = <int, _Ytd>{};
    final deductedMonths = <int>{};
    final out = <ProducedPayment>[];

    for (final p in pre) {
      final year = p.date.year;
      final scale = ndfl.scaleForYear(year);
      final st = byYear.putIfAbsent(year, () {
        final base = year == primaryYear ? profile.ytdGrossAtYearStart : 0;
        return _Ytd(base, roundRuble(scale.taxOn(base)));
      });

      var addition = p.gross;
      final monthKey = year * 100 + p.date.month;
      if (profile.monthlyDeduction > 0 && !deductedMonths.contains(monthKey)) {
        addition -= profile.monthlyDeduction;
        deductedMonths.add(monthKey);
      }

      st.taxable += addition;
      final ndflTotal = roundRuble(scale.taxOn(st.taxable));
      final ndflAmount = ndflTotal - st.withheld;
      st.withheld = ndflTotal;
      final net = roundKopeck(p.gross - ndflAmount);
      final marginal = scale.marginalRate(st.taxable);

      out.add(ProducedPayment(
        kind: p.kind,
        date: p.date,
        gross: p.gross,
        ndfl: ndflAmount,
        net: net,
        marginalRate: marginal,
        periodStart: p.periodStart,
        periodEnd: p.periodEnd,
      ));
    }
    return out;
  }

  // --- helpers ------------------------------------------------------------

  DateTime _payday(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final clamped = math.min(day, lastDay);
    return calendar.previousWorkingDay(DateTime(year, month, clamped));
  }

  int _vacationWorkingDaysWithin(
    DateTime vacStart,
    DateTime vacEnd,
    DateTime windowStart,
    DateTime windowEnd,
  ) {
    final from = vacStart.isAfter(windowStart) ? vacStart : windowStart;
    final to = vacEnd.isBefore(windowEnd) ? vacEnd : windowEnd;
    if (to.isBefore(from)) return 0;
    return calendar.workingDaysBetween(from, to);
  }

  List<_YearMonth> _touchedMonths(DateTime start, DateTime end) {
    final months = <_YearMonth>[];
    var y = start.year;
    var m = start.month;
    while (y < end.year || (y == end.year && m <= end.month)) {
      months.add(_YearMonth(y, m));
      if (m == 12) {
        y += 1;
        m = 1;
      } else {
        m += 1;
      }
    }
    return months;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

class _Pre {
  _Pre(this.kind, this.date, this.gross, {this.periodStart, this.periodEnd});

  final ProducedPaymentKind kind;
  final DateTime date;
  final num gross;
  final DateTime? periodStart;
  final DateTime? periodEnd;
}

class _Ytd {
  _Ytd(this.taxable, this.withheld);

  num taxable;
  num withheld;
}

class _AvgDaily {
  _AvgDaily(this.value, this.mrotFloorApplied);

  final num value;
  final bool mrotFloorApplied;
}

class _YearMonth {
  _YearMonth(this.year, this.month);

  final int year;
  final int month;
}
