// ignore_for_file: prefer_collection_literals

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PaymentsManagerBloc
    extends Bloc<PaymentsManagerEvent, PaymentsManagerState> {
  PaymentsManagerBloc() : super(PaymentsManagerInitialState()) {
    _onComputeBudget();
  }

  void computeBudget(PaymentsManagerEvent event) {
    assert(event is PaymentsManagerComputeBudgetEvent);
    add(event);
  }

  void _onComputeBudget() {
    on<PaymentsManagerComputeBudgetEvent>(
      transformer: restartable(),
      (event, emit) {
        Timeline.startSync('generate_budget');

        final computeBudgetUseCase = ComputeBudgetUseCase(
          args: ComputeBudgetUseCaseArgs(
            payments: event.payments,
            startPeriod: event.startPeriod,
            endPeriod: event.endPeriod,
            initialBudget: event.initialBudget ?? 0,
          ),
        );

        final result = computeBudgetUseCase.run();
        Timeline.finishSync();

        final moneyFlow = MoneyFlowUseCase(
          args: MoneyFlowUseCaseArgs(
            payments: result.paymentsGenerated,
            initialBudget: event.initialBudget ?? 0,
          ),
        ).run();

        final newState = PaymentsManagerState.budgetComputed(
          paymentsOriginal: result.paymentsOriginal.toIList(),
          paymentsGenerated: result.paymentsGenerated.toIList(),
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
