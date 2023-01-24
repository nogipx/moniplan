// ignore_for_file: prefer_collection_literals

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

        final computeBudgetUseCase = ComputeBudgetUseCase(
          args: ComputeBudgetUseCaseArgs(
            operations: event.operations,
            dateStart: event.startPeriod,
            dateEnd: event.endPeriod,
            initialBudget: event.initialBudget ?? 0,
          ),
        );

        // if (event.operations.any((e) => e.receipt.name.contains('OhSofia'))) {
        //   print('');
        // }

        final result = computeBudgetUseCase.run();
        Timeline.finishSync();

        final moneyFlow = MoneyFlowUseCase(
          args: MoneyFlowUseCaseArgs(
            operations: result.operationsGenerated,
            initialBudget: event.initialBudget ?? 0,
          ),
        ).run();

        final newState = OperationsManagerState.budgetComputed(
          operationsOriginal: result.operationsOriginal.toIList(),
          operationsGenerated: result.operationsGenerated.toIList(),
          budget: IMap.fromEntries(result.mediateBudget.entries),
          dateStart: result.dateStart,
          dateEnd: result.dateEnd,
          moneyFlow: moneyFlow,
        );
        emit(newState);
      },
    );
  }
}
