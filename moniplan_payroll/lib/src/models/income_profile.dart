import 'package:freezed_annotation/freezed_annotation.dart';

import 'earnings.dart';

part 'income_profile.freezed.dart';

/// The two monthly paydays (day-of-month). Weekend/holiday shift is applied by
/// the engine (art. 136: to the previous working day).
@freezed
abstract class PaySchedule with _$PaySchedule {
  const factory PaySchedule({
    /// Payday for the first half of the month (default 20).
    @Default(20) int firstHalfDay,

    /// Payday for the second half, paid in the next month (default 5).
    @Default(5) int secondHalfDay,
  }) = _PaySchedule;
}

/// Income profile (spec 4.1). Quick mode uses [grossMonthly]; precise mode
/// uses [earnings] (possibly partial — missing months fall back to
/// [grossMonthly], the hybrid case).
@freezed
abstract class IncomeProfile with _$IncomeProfile {
  const factory IncomeProfile({
    required String id,
    required String title,

    /// Current gross salary — the base of quick mode.
    required num grossMonthly,
    @Default(PaySchedule()) PaySchedule paySchedule,

    /// Month-by-month base for precise mode. May be partial.
    @Default(<MonthlyEarnings>[]) List<MonthlyEarnings> earnings,
    @Default(<IndexationEvent>[]) List<IndexationEvent> indexations,

    /// Gross accrued this calendar year before the first computed payment.
    /// Feeds the cumulative NDFL base. 0 means "everything at 13%".
    @Default(0) num ytdGrossAtYearStart,

    /// Standard deductions — reduce the NDFL base once per month.
    @Default(0) num monthlyDeduction,
  }) = _IncomeProfile;
}
