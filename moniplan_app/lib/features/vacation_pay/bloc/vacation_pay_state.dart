part of 'vacation_pay_cubit.dart';

class VacationPayState extends Equatable {
  const VacationPayState({
    required this.grossMonthly,
    required this.ytd,
    required this.manualAdjustment,
    required this.firstHalfDay,
    required this.secondHalfDay,
    required this.vacationStart,
    required this.vacationEnd,
    required this.enabled,
    this.result,
    this.error,
  });

  factory VacationPayState.initial(DateTime today) {
    final start = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 14));
    final end = start.add(const Duration(days: 13)); // two weeks, inclusive
    return VacationPayState(
      grossMonthly: 100000,
      ytd: 0,
      manualAdjustment: 0,
      firstHalfDay: 20,
      secondHalfDay: 5,
      vacationStart: start,
      vacationEnd: end,
      enabled: const [],
    );
  }

  final num grossMonthly;
  final num ytd;
  final num manualAdjustment;
  final int firstHalfDay;
  final int secondHalfDay;
  final DateTime vacationStart;
  final DateTime vacationEnd;

  /// Per-payment import selection, parallel to [PayrollResult.payments].
  final List<bool> enabled;

  final PayrollResult? result;
  final String? error;

  bool get hasResult => result != null;

  Iterable<int> get _selectedIndexes sync* {
    for (var i = 0; i < enabled.length; i++) {
      if (enabled[i]) {
        yield i;
      }
    }
  }

  int get selectedCount => _selectedIndexes.length;

  num get selectedNet {
    final r = result;
    if (r == null) {
      return 0;
    }
    var sum = 0.0;
    for (final i in _selectedIndexes) {
      if (i < r.payments.length) {
        sum += r.payments[i].net;
      }
    }
    return sum;
  }

  /// Copy of the input fields only; result/error are recomputed by the cubit.
  VacationPayState copyInputs({
    num? grossMonthly,
    num? ytd,
    num? manualAdjustment,
    int? firstHalfDay,
    int? secondHalfDay,
    DateTime? vacationStart,
    DateTime? vacationEnd,
  }) {
    return VacationPayState(
      grossMonthly: grossMonthly ?? this.grossMonthly,
      ytd: ytd ?? this.ytd,
      manualAdjustment: manualAdjustment ?? this.manualAdjustment,
      firstHalfDay: firstHalfDay ?? this.firstHalfDay,
      secondHalfDay: secondHalfDay ?? this.secondHalfDay,
      vacationStart: vacationStart ?? this.vacationStart,
      vacationEnd: vacationEnd ?? this.vacationEnd,
      enabled: enabled,
      result: result,
      error: error,
    );
  }

  VacationPayState withResult(PayrollResult result, {required List<bool> enabled}) {
    return VacationPayState(
      grossMonthly: grossMonthly,
      ytd: ytd,
      manualAdjustment: manualAdjustment,
      firstHalfDay: firstHalfDay,
      secondHalfDay: secondHalfDay,
      vacationStart: vacationStart,
      vacationEnd: vacationEnd,
      enabled: enabled,
      result: result,
    );
  }

  VacationPayState withError(String error) {
    return VacationPayState(
      grossMonthly: grossMonthly,
      ytd: ytd,
      manualAdjustment: manualAdjustment,
      firstHalfDay: firstHalfDay,
      secondHalfDay: secondHalfDay,
      vacationStart: vacationStart,
      vacationEnd: vacationEnd,
      enabled: const [],
      error: error,
    );
  }

  VacationPayState withSelection(List<bool> enabled) {
    return VacationPayState(
      grossMonthly: grossMonthly,
      ytd: ytd,
      manualAdjustment: manualAdjustment,
      firstHalfDay: firstHalfDay,
      secondHalfDay: secondHalfDay,
      vacationStart: vacationStart,
      vacationEnd: vacationEnd,
      enabled: enabled,
      result: result,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        grossMonthly,
        ytd,
        manualAdjustment,
        firstHalfDay,
        secondHalfDay,
        vacationStart,
        vacationEnd,
        enabled,
        result,
        error,
      ];
}
