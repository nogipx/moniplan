// ignore_for_file: prefer_collection_literals

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final IPlannerRepo _plannerRepo;
  final String plannerId;

  PlannerBloc({
    required this.plannerId,
    required IPlannerRepo paymentPlannerRepo,
  })  : _plannerRepo = paymentPlannerRepo,
        super(PlannerInitialState()) {
    on<PlannerComputeBudgetEvent>(
      _onCompute,
      transformer: restartable(),
    );
    on<PlannerUpdatePaymentEvent>(
      _onUpdatePayment,
      transformer: restartable(),
    );
  }

  FutureOr<void> _onCompute(
    PlannerComputeBudgetEvent event,
    Emitter<PlannerState> emit,
  ) async {
    final id = plannerId;
    final payments = await _plannerRepo.getPaymentsByPlannerId(plannerId: id);
    final planner = await _plannerRepo.getPlannerById(id);

    if (planner != null) {
      final newState = _computeStateFromPlanner(planner.copyWith(payments: payments)).copyWith(
        plannerId: id,
      );

      emit(newState);
    }
  }

  FutureOr<void> _onUpdatePayment(
    PlannerUpdatePaymentEvent event,
    Emitter<PlannerState> emit,
  ) async {
    final result = await _plannerRepo.savePayment(
      plannerId: plannerId,
      payment: event.newPayment,
    );

    if (result != null) {
      add(PlannerEvent.computeBudget());
    }
  }

  PlannerState _computeStateFromPlanner(PaymentPlanner planner) {
    var targetPlanner = planner.copyWith();
    if (planner.isGenerationAllowed) {
      final result = GenerateNewPlannerUseCase(
        args: GenerateNewPlannerUseCaseArgs(
          customPlannerId: targetPlanner.id,
          payments: targetPlanner.payments,
          dateStart: targetPlanner.dateStart,
          dateEnd: targetPlanner.dateEnd,
          initialBudget: targetPlanner.initialBudget,
        ),
      ).run();
      targetPlanner = result.planner.copyWith(
        id: targetPlanner.id,
        isGenerationAllowed: false,
      );
    }

    if (targetPlanner.isGenerationAllowed) {
      throw Exception('Cannot work with not generated planner');
    }

    final constrainedPayments = ConstrainItemsInPeriod(
      args: ConstrainItemsInPeriodArgs(
        items: targetPlanner.payments,
        dateStart: targetPlanner.dateStart,
        dateEnd: targetPlanner.dateEnd,
        dateExtractor: (payment) => payment.date,
      ),
    ).run();

    final computedBudget = ComputeBudgetUseCase(
      args: ComputeBudgetUseCaseArgs(
        payments: constrainedPayments.constrained,
        initialBudget: targetPlanner.initialBudget,
      ),
    ).run();

    final moneyFlow = MoneyFlowUseCase(
      args: MoneyFlowUseCaseArgs(
        payments: constrainedPayments.constrained,
        initialBudget: targetPlanner.initialBudget,
      ),
    ).run();

    final newState = PlannerState.budgetComputed(
      paymentsGenerated: constrainedPayments.constrained.toList(),
      budget: Map.from(computedBudget.budget),
      dateStart: targetPlanner.dateStart,
      dateEnd: targetPlanner.dateEnd,
      moneyFlow: moneyFlow,
    );
    return newState;
  }
}
