import 'dart:collection';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'operations_manager_state.freezed.dart';

@Freezed()
class OperationsManagerState with _$OperationsManagerState {
  const factory OperationsManagerState.initial() =
      OperationsManagerInitialState;

  const factory OperationsManagerState.budgetComputed({
    @Default(IListConst([])) IList<Operation> operationsOriginal,
    @Default(IListConst([])) IList<Operation> operationsGenerated,
    @Default({}) Map<Operation, double> budget,
  }) = OperationsManagerBudgetComputedState;

  const factory OperationsManagerState.error({
    @Default(IListConst([])) IList<Operation> operations,
  }) = OperationsManagerErrorState;
}
