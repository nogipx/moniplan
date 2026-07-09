/// Calculation modes with progressive disclosure (spec 1.1.5).
enum CalcMode {
  /// Salary-only, three inputs. avgDaily = grossMonthly / 29.3.
  quick,

  /// Month-by-month base over 12 months per Decree 922.
  precise,
}

/// Kind of a payment produced by the engine.
enum ProducedPaymentKind {
  vacationPay,
  firstHalfSalary,
  secondHalfSalary,
  dismissalCompensation,
  latePaymentCompensation,
}

/// Bonus classification per clause 15 of Decree 922.
enum BonusKind {
  monthly,
  quarterly,
  annual,
  oneTimeForWork,
  oneTimeNotForWork,
}

/// Kind of a period excluded from the averaging base (clause 5 of Decree 922).
enum ExcludedKind {
  sickLeave,
  businessTrip,
  priorVacation,
  unpaidLeave,
  downtime,
  other,
}

/// Typed warnings surfaced in [breakdown.warnings].
enum PayrollWarningKind {
  /// Vacation-pay statutory deadline (3 days before) already passed.
  latePaymentDeadlineMissed,

  /// Vacation earlier than 6 months of tenure (art. 122 allows by agreement).
  vacationBeforeSixMonths,

  /// MROT floor kicked in (usually a sign of incompletely entered base).
  mrotFloorApplied,

  /// IndexationEvent with organizationWide == false was ignored.
  personalIndexationIgnored,

  /// A calendar month fully consisted of excluded days (daysCounted == 0).
  monthFullyExcluded,
}
