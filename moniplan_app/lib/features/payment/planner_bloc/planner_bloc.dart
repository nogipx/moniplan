// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: prefer_collection_literals

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import 'planner_event.dart';
import 'planner_state.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final IPlannerRepo _plannerRepo;
  final String plannerId;

  PlannerBloc({required this.plannerId, required IPlannerRepo paymentPlannerRepo})
    : _plannerRepo = paymentPlannerRepo,
      super(PlannerInitialState()) {
    on<PlannerComputeBudgetEvent>((e, emit) => _onCompute(e, emit), transformer: droppable());

    on<PlannerEvent>(
      (e, emit) => switch (e) {
        PlannerUpdatePaymentEvent() => _onUpdatePayment(e, emit),
        PlannerDeletePaymentEvent() => _onDeletePayment(e, emit),
        PlannerFixateRepeatedPaymentEvent() => _onFixateRepeatedPayment(e, emit),
        _ => emit(state),
      },
      transformer: sequential(),
    );
  }

  FutureOr<void> _onCompute(PlannerComputeBudgetEvent event, Emitter<PlannerState> emit) async {
    final id = plannerId;
    final payments = await _plannerRepo.getPaymentsByPlannerId(plannerId: id);
    final planner = await _plannerRepo.getPlannerById(id);

    if (planner != null) {
      final newState = (await _computeStateFromPlanner(
        planner.copyWith(payments: payments),
      )).copyWith(plannerId: id);

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
        emit(state.copyWith(errors: canApplyUpdate.errorKeys));
        return;
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
        await _onCompute(const PlannerComputeBudgetEvent(), emit);
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
    await _plannerRepo.deletePayment(plannerId: plannerId, paymentId: event.paymentId);

    await _onCompute(const PlannerComputeBudgetEvent(), emit);
  }

  Future<void> _onFixateRepeatedPayment(
    PlannerFixateRepeatedPaymentEvent event,
    Emitter<PlannerState> emit,
  ) async {
    await _plannerRepo.fixateRepeatedPayment(plannerId: plannerId, paymentId: event.paymentId);

    await _onCompute(const PlannerComputeBudgetEvent(), emit);
  }

  Future<PlannerState> _computeStateFromPlanner(Planner planner) async {
    var targetPlanner = planner.copyWith();
    if (planner.isGenerationAllowed) {
      final result =
          GenerateNewPlannerUseCase(
            customPlannerId: targetPlanner.id,
            payments: targetPlanner.payments,
            dateStart: targetPlanner.dateStart,
            dateEnd: targetPlanner.dateEnd,
            initialBudget: targetPlanner.initialBudget,
          ).run();
      targetPlanner = result.planner.copyWith(id: targetPlanner.id, isGenerationAllowed: false);
    }

    if (targetPlanner.isGenerationAllowed) {
      throw Exception('Cannot work with not generated planner');
    }

    final constrainedPayments =
        ConstrainItemsInPeriodUseCase(
          items: targetPlanner.payments,
          dateStart: targetPlanner.dateStart,
          dateEnd: targetPlanner.dateEnd,
          dateExtractor: (payment) => payment.date,
        ).run();

    final computedBudget =
        ComputeBudgetUseCase(
          payments: constrainedPayments,
          initialBudget: targetPlanner.initialBudget,
        ).run();

    final moneyFlow =
        MoneyFlowUseCase(
          payments: constrainedPayments,
          initialBudget: targetPlanner.initialBudget,
        ).run();

    final paymentsByDate =
        GroupPaymentsByDateUsecase(payments: constrainedPayments, today: DateTime.now()).run();

    final actualInfo =
        ComputeActualPlannerInfo(
          plannerId: targetPlanner.id,
          lastUpdatedBudget: computedBudget.lastUpdatedBudget,
          payments: constrainedPayments,
        ).run();

    final newState = PlannerState.budgetComputed(
      payments: constrainedPayments,
      paymentsByDate: paymentsByDate,
      budget: Map.from(computedBudget.budget),
      dateStart: targetPlanner.dateStart,
      dateEnd: targetPlanner.dateEnd,
      moneyFlow: moneyFlow,
      actualInfo: actualInfo,
    );

    return newState;
  }
}
