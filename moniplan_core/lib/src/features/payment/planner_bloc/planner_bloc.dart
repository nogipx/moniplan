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
      transformer: sequential(),
    );
    on<PlannerDeletePaymentEvent>(
      _onDeletePayment,
      transformer: sequential(),
    );
    on<PlannerFixateRepeatedPaymentEvent>(
      _onFixateRepeatedPayment,
      transformer: sequential(),
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
    try {
      final canApplyUpdate = CheckPaymentCanApplyUpdate(updatedPayment: event.newPayment).run();
      if (!canApplyUpdate.canUpdate) {
        emit(state.copyWith(
          errors: canApplyUpdate.errorKeys,
        ));
      }

      final result = await _plannerRepo.savePayment(
        plannerId: plannerId,
        payment: event.newPayment.copyWith(
          // dateStart больше не нужен, поскольку больше не генерируем платежи прошлого
          dateStart: null,
        ),
        allowCreate: event.create,
      );

      if (result != null) {
        add(PlannerEvent.computeBudget());
      }
    } on Object catch (e) {
      print(e);
      rethrow;
    }
  }

  FutureOr<void> _onDeletePayment(
    PlannerDeletePaymentEvent event,
    Emitter<PlannerState> emit,
  ) async {
    await _plannerRepo.deletePayment(
      plannerId: plannerId,
      paymentId: event.paymentId,
    );

    add(PlannerEvent.computeBudget());
  }

  Future<void> _onFixateRepeatedPayment(
    PlannerFixateRepeatedPaymentEvent event,
    Emitter<PlannerState> emit,
  ) async {
    await _plannerRepo.fixateRepeatedPayment(
      plannerId: plannerId,
      paymentId: event.paymentId,
    );

    add(PlannerEvent.computeBudget());
  }

  PlannerState _computeStateFromPlanner(Planner planner) {
    var targetPlanner = planner.copyWith();
    if (planner.isGenerationAllowed) {
      final result = GenerateNewPlannerUseCase(
        customPlannerId: targetPlanner.id,
        payments: targetPlanner.payments,
        dateStart: targetPlanner.dateStart,
        dateEnd: targetPlanner.dateEnd,
        initialBudget: targetPlanner.initialBudget,
      ).run();
      targetPlanner = result.planner.copyWith(
        id: targetPlanner.id,
        isGenerationAllowed: false,
      );
    }

    if (targetPlanner.isGenerationAllowed) {
      throw Exception('Cannot work with not generated planner');
    }

    final constrainedPayments = ConstrainItemsInPeriodUseCase(
      items: targetPlanner.payments,
      dateStart: targetPlanner.dateStart,
      dateEnd: targetPlanner.dateEnd,
      dateExtractor: (payment) => payment.date,
    ).run();

    final computedBudget = ComputeBudgetUseCase(
      payments: constrainedPayments,
      initialBudget: targetPlanner.initialBudget,
    ).run();

    final moneyFlow = MoneyFlowUseCase(
      payments: constrainedPayments,
      initialBudget: targetPlanner.initialBudget,
    ).run();

    final paymentsByDate = GroupPaymentsByDateUsecase(
      payments: constrainedPayments,
      today: DateTime.now(),
    ).run();

    final actualInfo = ComputeActualPlannerInfo(
      plannerId: targetPlanner.id,
      lastUpdatedBudget: computedBudget.lastUpdatedBudget,
      payments: constrainedPayments,
    ).run();

    unawaited(_plannerRepo.updatePlannerActualInfo(
      plannerId: plannerId,
      plannerActualInfo: actualInfo,
    ));

    final newState = PlannerState.budgetComputed(
      payments: constrainedPayments,
      paymentsByDate: paymentsByDate,
      budget: Map.from(computedBudget.budget),
      dateStart: targetPlanner.dateStart,
      dateEnd: targetPlanner.dateEnd,
      moneyFlow: moneyFlow,
    );

    return newState;
  }
}
