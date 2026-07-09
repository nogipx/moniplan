import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'income_profile.dart';

part 'payroll_request.freezed.dart';

/// Engine input (spec 4.3). A sealed union of the two supported scenarios.
@freezed
sealed class PayrollRequest with _$PayrollRequest {
  const PayrollRequest._();

  const factory PayrollRequest.vacation({
    required IncomeProfile profile,

    /// Inclusive.
    required DateTime vacationStart,

    /// Inclusive.
    required DateTime vacationEnd,
    required CalcMode mode,

    /// Manual gross correction on vacation pay.
    @Default(0) num manualAdjustment,

    /// Add art. 236 compensation if the payment deadline is missed.
    @Default(false) bool includeLatePaymentCompensation,
  }) = VacationRequest;

  const factory PayrollRequest.dismissalCompensation({
    required IncomeProfile profile,
    required DateTime dismissalDate,

    /// Fractional days allowed; entered by the user.
    required double unusedVacationDays,
    required CalcMode mode,
  }) = DismissalRequest;

  /// The income profile, regardless of scenario.
  @override
  IncomeProfile get profile => switch (this) {
        VacationRequest(:final profile) => profile,
        DismissalRequest(:final profile) => profile,
      };

  /// The calculation mode, regardless of scenario.
  @override
  CalcMode get mode => switch (this) {
        VacationRequest(:final mode) => mode,
        DismissalRequest(:final mode) => mode,
      };
}
