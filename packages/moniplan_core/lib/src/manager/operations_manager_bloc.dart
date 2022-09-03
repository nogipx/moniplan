// ignore_for_file: prefer_collection_literals

import 'dart:collection';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:moniplan_core/moniplan_core.dart';

class OperationsManagerBloc
    extends Bloc<OperationsManagerEvent, OperationsManagerState> {
  OperationsManagerBloc() : super(OperationsManagerInitialState()) {
    _onComputeBudget();
  }

  void computeBudget(OperationsManagerEvent event) {
    assert(event is OperationsManagerComputeBudgetEvent);
    add(event);
  }

  void _onComputeBudget() {
    on<OperationsManagerComputeBudgetEvent>(
      transformer: restartable(),
      (event, emit) {
        Timeline.startSync('generate_budget');
        final startOperationDay = event.operations.fold(
          event.operations.first.date,
          (date, next) {
            return next.date.isBefore(date) ? next.date : date;
          },
        );
        final lastOperationDay = event.operations.fold(
          DateTime(-1),
          (date, next) {
            return next.date.isAfter(date) ? next.date : date;
          },
        );

        final originalOperations = event.operations.toIList();

        final allOperations = originalOperations
            .map(
              (e) => e
                  .getPeriodOperations(
                    event.startPeriod ?? startOperationDay,
                    event.endPeriod ?? lastOperationDay,
                  )
                  .unlock
                ..add(e),
            )
            .expand((e) => e)
            .toIList()
            .unlock;

        allOperations.sortOrdered((a, b) => a.date.compareTo(b.date));

        final budget = LinkedHashMap<Operation, double>();
        var tempBudget = 0.0;
        for (final item in allOperations) {
          tempBudget += item.money * item.type.modifier;
          budget[item] = tempBudget;
        }

        Timeline.finishSync();
        final newState = OperationsManagerState.budgetComputed(
          operationsOriginal: originalOperations,
          operationsGenerated: allOperations.lock,
          budget: budget,
        );
        emit(newState);
      },
    );
  }
}
