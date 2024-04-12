// ignore_for_file: prefer_collection_literals

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PaymentsManagerBloc extends Bloc<PaymentsManagerEvent, PaymentsManagerState> {
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

        var targetPlanner = event.planner.copyWith();
        if (targetPlanner.shouldGenerate) {
          final result = GeneratePlannerUseCase(
            args: GeneratePlannerUseCaseArgs(
              payments: targetPlanner.payments,
              startPeriod: targetPlanner.dateStart,
              endPeriod: targetPlanner.dateEnd,
            ),
          ).run();
          targetPlanner = PaymentPlanner(
            id: targetPlanner.id,
            dateStart: result.startPeriod,
            dateEnd: result.endPeriod,
            payments: result.generatedPayments.toList(),
            initialBudget: targetPlanner.initialBudget,
            shouldGenerate: false,
          );
        }

        final payments = ConstrainItemsInPeriod(
          args: ConstrainItemsInPeriodArgs(
            items: targetPlanner.payments,
            dateStart: targetPlanner.dateStart,
            dateEnd: targetPlanner.dateEnd,
            dateExtractor: (payment) => payment.date,
          ),
        ).run();

        final budgetResult = ComputeBudgetUseCase(
          args: ComputeBudgetUseCaseArgs(
            payments: payments.constrained,
            initialBudget: targetPlanner.initialBudget,
          ),
        ).run();

        Timeline.finishSync();

        final moneyFlow = MoneyFlowUseCase(
          args: MoneyFlowUseCaseArgs(
            payments: payments.constrained,
            initialBudget: targetPlanner.initialBudget,
          ),
        ).run();

        final newState = PaymentsManagerState.budgetComputed(
          paymentsGenerated: payments.constrained.toList(),
          budget: Map.from(budgetResult.budget),
          dateStart: targetPlanner.dateStart,
          dateEnd: targetPlanner.dateEnd,
          moneyFlow: moneyFlow,
        );
        emit(newState);
      },
    );
  }
}
