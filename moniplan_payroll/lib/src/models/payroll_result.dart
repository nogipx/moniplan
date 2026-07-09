import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'payroll_result.freezed.dart';

/// A single payment produced by the engine (spec 4.3).
@freezed
abstract class ProducedPayment with _$ProducedPayment {
  const factory ProducedPayment({
    required ProducedPaymentKind kind,
    required DateTime date,
    required num gross,
    required num ndfl,
    required num net,

    /// Rate on the last ruble — for display.
    required double marginalRate,

    /// Inclusive period this payment covers (vacation range, or the worked
    /// half-month). Drives display labels and mapped payment names.
    DateTime? periodStart,
    DateTime? periodEnd,
  }) = _ProducedPayment;
}

/// Per-month averaging base breakdown, reconcilable with a payslip.
@freezed
abstract class MonthBreakdown with _$MonthBreakdown {
  const factory MonthBreakdown({
    required int year,
    required int month,

    /// Base counted for this month (salary part * indexation + bonuses).
    required num base,

    /// 29.3 for a fully worked month, or the proportion otherwise.
    required num daysCounted,

    /// True if this month was filled from grossMonthly (hybrid, quick).
    @Default(false) bool filledFromSalary,
    @Default(0) num bonusesIncluded,
    @Default(1.0) double indexation,
  }) = _MonthBreakdown;
}

/// First-class breakdown (spec 4.3). Every preview figure decomposes here.
@freezed
abstract class PayrollBreakdown with _$PayrollBreakdown {
  const factory PayrollBreakdown({
    required num avgDailyEarnings,
    @Default(<MonthBreakdown>[]) List<MonthBreakdown> months,
    @Default(0) num payableVacationDays,
    @Default(0) num totalBase,
    @Default(0) num totalDays,
    @Default(false) bool mrotFloorApplied,
    @Default(<PayrollWarning>[]) List<PayrollWarning> warnings,
  }) = _PayrollBreakdown;
}

/// Typed warning (spec 6).
@freezed
abstract class PayrollWarning with _$PayrollWarning {
  const factory PayrollWarning({
    required PayrollWarningKind kind,
    required String message,
  }) = _PayrollWarning;
}

/// Engine output (spec 4.3).
@freezed
abstract class PayrollResult with _$PayrollResult {
  const factory PayrollResult({
    required List<ProducedPayment> payments,
    required PayrollBreakdown breakdown,
  }) = _PayrollResult;
}
