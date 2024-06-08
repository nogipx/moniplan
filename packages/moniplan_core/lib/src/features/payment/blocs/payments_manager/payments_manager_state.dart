import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'payments_manager_state.freezed.dart';

@Freezed()
class PaymentsManagerState with _$PaymentsManagerState {
  const PaymentsManagerState._();

  const factory PaymentsManagerState.initial({
    @Default('') String plannerId,
  }) = PaymentsManagerInitialState;

  const factory PaymentsManagerState.budgetComputed({
    @Default('') String plannerId,
    DateTime? dateStart,
    DateTime? dateEnd,
    @Default([]) List<Payment> paymentsGenerated,
    @Default({}) Map<Payment, num> budget,
    @Default(MoneyFlowUseCaseResult()) MoneyFlowUseCaseResult moneyFlow,
  }) = PaymentsManagerBudgetComputedState;

  const factory PaymentsManagerState.error({
    @Default('') String plannerId,
    @Default([]) List<Payment> payments,
  }) = PaymentsManagerErrorState;

  List<Payment> get paymentsGenerated => maybeMap<List<Payment>>(
        budgetComputed: (v) => v.paymentsGenerated,
        orElse: () => const [],
      );

  Map<Payment, num> get budget => maybeMap<Map<Payment, num>>(
        budgetComputed: (v) => v.budget,
        orElse: () => const {},
      );
}
