import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'earnings.freezed.dart';

/// Month-by-month accruals for precise mode (spec 4.2).
@freezed
abstract class MonthlyEarnings with _$MonthlyEarnings {
  const factory MonthlyEarnings({
    required int year,
    required int month,

    /// Accrued for time actually worked.
    required num baseSalary,
    @Default(<Bonus>[]) List<Bonus> bonuses,
    @Default(<ExcludedPeriod>[]) List<ExcludedPeriod> excludedPeriods,
  }) = _MonthlyEarnings;
}

/// A period excluded from the averaging base together with its amount.
@freezed
abstract class ExcludedPeriod with _$ExcludedPeriod {
  const factory ExcludedPeriod({
    required DateTime start,

    /// Inclusive.
    required DateTime end,
    required ExcludedKind kind,

    /// Accrued for this period (by average / sick pay) — excluded with the days.
    @Default(0) num accruedAmount,
  }) = _ExcludedPeriod;
}

/// A bonus with the period it was earned for.
@freezed
abstract class Bonus with _$Bonus {
  const factory Bonus({
    required BonusKind kind,
    required num amount,
    required DateTime periodStart,
    required DateTime periodEnd,

    /// Earned proportionally to time worked? If false and the period is not
    /// fully worked, the engine prorates it itself.
    @Default(true) bool proportionalToTime,
  }) = _Bonus;
}

/// A salary indexation event (clause 16 of Decree 922).
@freezed
abstract class IndexationEvent with _$IndexationEvent {
  const factory IndexationEvent({
    required DateTime effectiveDate,

    /// new salary / old salary.
    required double coefficient,

    /// Org-wide raise — the condition to apply clause 16.
    @Default(true) bool organizationWide,
  }) = _IndexationEvent;
}
