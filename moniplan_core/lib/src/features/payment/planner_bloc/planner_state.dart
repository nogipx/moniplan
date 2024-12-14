import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'planner_state.freezed.dart';

@Freezed()
class PlannerState with _$PlannerState {
  const PlannerState._();

  const factory PlannerState.initial({
    @Default('') String plannerId,
    @Default({}) Set<String> errors,
  }) = PlannerInitialState;

  const factory PlannerState.budgetComputed({
    @Default('') String plannerId,
    DateTime? dateStart,
    DateTime? dateEnd,
    @Default([]) List<Payment> payments,
    @Default([]) List<PaymentsDateGrouped> paymentsByDate,
    @Default({}) Map<Payment, num> budget,
    @Default(MoneyFlowUseCaseResult()) MoneyFlowUseCaseResult moneyFlow,
    @Default({}) Set<String> errors,
  }) = PlannerBudgetComputedState;

  const factory PlannerState.error({
    @Default('') String plannerId,
    @Default([]) List<Payment> payments,
    @Default({}) Set<String> errors,
  }) = PlannerErrorState;

  List<Payment> get getPayments => maybeMap<List<Payment>>(
        budgetComputed: (v) => v.payments,
        orElse: () => const [],
      );

  List<PaymentsDateGrouped> get getPaymentsByDate => maybeMap<List<PaymentsDateGrouped>>(
        budgetComputed: (v) => v.paymentsByDate,
        orElse: () => const [],
      );

  Map<Payment, num> get budget => maybeMap<Map<Payment, num>>(
        budgetComputed: (v) => v.budget,
        orElse: () => const {},
      );
}

extension ListPaymentsByDateExt on List<PaymentsDateGrouped> {
  ({int index, double alignment})? getIndexOfDate(DateTime date) {
    final searchDay = date.dayBound;

    const topAlignment = 0.15;
    const centerAlignment = 0.5;
    const bottomAlignment = 0.75;

    ({int index, double alignment})? result;

    for (var i = 1; i < length - 1; i++) {
      final prevDayIndex = i - 1;
      final nextDayIndex = i;

      final prevDay = this[prevDayIndex].date.dayBound;
      final nextDay = this[nextDayIndex].date.dayBound;

      final isDateInRange = prevDay.compareTo(date) <= 0 && nextDay.compareTo(date) >= 0;

      if (!isDateInRange) {
        continue;
      }

      if (prevDay.isSameDay(searchDay)) {
        result = (
          index: prevDayIndex,
          alignment: topAlignment,
        );
      } else if (nextDay.isSameDay(searchDay)) {
        result = (
          index: nextDayIndex,
          alignment: centerAlignment,
        );
      } else {
        result = (
          index: nextDayIndex,
          alignment: centerAlignment,
        );
      }
    }

    return result;
  }

  ({PaymentsDateGrouped? before, PaymentsDateGrouped? after})? getNeighbours(int index) {
    final before = index == 0 ? null : elementAtOrNull(index - 1);
    final after = index == length - 1 ? null : elementAtOrNull(index + 1);
    return (
      before: before,
      after: after,
    );
  }
}
