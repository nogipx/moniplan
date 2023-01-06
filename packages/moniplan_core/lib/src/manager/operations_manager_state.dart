import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'operations_manager_state.freezed.dart';

@Freezed()
class OperationsManagerState with _$OperationsManagerState {
  const OperationsManagerState._();

  const factory OperationsManagerState.initial() =
      OperationsManagerInitialState;

  const factory OperationsManagerState.budgetComputed({
    DateTime? dateStart,
    DateTime? dateEnd,
    @Default(IListConst([])) IList<Operation> operationsOriginal,
    @Default(IListConst([])) IList<Operation> operationsGenerated,
    @Default(IMapConst({})) IMap<Operation, double> budget,
    @Default(MoneyFlowUseCaseResult()) MoneyFlowUseCaseResult moneyFlow,
  }) = OperationsManagerBudgetComputedState;

  const factory OperationsManagerState.error({
    @Default(IListConst([])) IList<Operation> operations,
  }) = OperationsManagerErrorState;

  IList<Operation> get operationsGenerated => maybeMap<IList<Operation>>(
        budgetComputed: (v) => v.operationsGenerated,
        orElse: () => const IListConst([]),
      );

  IMap<Operation, double> get budget => maybeMap<IMap<Operation, double>>(
        budgetComputed: (v) => v.budget,
        orElse: () => const IMapConst({}),
      );
}
