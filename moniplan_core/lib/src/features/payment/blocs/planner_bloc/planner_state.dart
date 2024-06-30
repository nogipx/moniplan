import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'planner_state.freezed.dart';

@Freezed()
class PlannerState with _$PlannerState {
  const PlannerState._();

  const factory PlannerState.initial({
    @Default('') String plannerId,
  }) = PlannerInitialState;

  const factory PlannerState.budgetComputed({
    @Default('') String plannerId,
    DateTime? dateStart,
    DateTime? dateEnd,
    @Default([]) List<Payment> paymentsGenerated,
    @Default({}) Map<Payment, num> budget,
    @Default(MoneyFlowUseCaseResult()) MoneyFlowUseCaseResult moneyFlow,
  }) = PlannerBudgetComputedState;

  const factory PlannerState.error({
    @Default('') String plannerId,
    @Default([]) List<Payment> payments,
  }) = PlannerErrorState;

  List<Payment> get paymentsGenerated => maybeMap<List<Payment>>(
        budgetComputed: (v) => v.paymentsGenerated,
        orElse: () => const [],
      );

  Map<Payment, num> get budget => maybeMap<Map<Payment, num>>(
        budgetComputed: (v) => v.budget,
        orElse: () => const {},
      );
}
