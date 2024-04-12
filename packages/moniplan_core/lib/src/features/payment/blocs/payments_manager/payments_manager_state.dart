import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'payments_manager_state.freezed.dart';

@Freezed()
class PaymentsManagerState with _$PaymentsManagerState {
  const PaymentsManagerState._();

  const factory PaymentsManagerState.initial() = PaymentsManagerInitialState;

  const factory PaymentsManagerState.budgetComputed({
    DateTime? dateStart,
    DateTime? dateEnd,
    @Default(IListConst([])) IList<Payment> paymentsGenerated,
    @Default(IMapConst({})) IMap<Payment, num> budget,
    @Default(MoneyFlowUseCaseResult()) MoneyFlowUseCaseResult moneyFlow,
  }) = PaymentsManagerBudgetComputedState;

  const factory PaymentsManagerState.error({
    @Default(IListConst([])) IList<Payment> payments,
  }) = PaymentsManagerErrorState;

  IList<Payment> get paymentsGenerated => maybeMap<IList<Payment>>(
        budgetComputed: (v) => v.paymentsGenerated,
        orElse: () => const IListConst([]),
      );

  IMap<Payment, num> get budget => maybeMap<IMap<Payment, num>>(
        budgetComputed: (v) => v.budget,
        orElse: () => const IMapConst({}),
      );
}
