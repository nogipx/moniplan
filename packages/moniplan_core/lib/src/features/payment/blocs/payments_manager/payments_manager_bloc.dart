// ignore_for_file: prefer_collection_literals

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PaymentsManagerBloc extends Bloc<PaymentsManagerEvent, PaymentsManagerState> {
  PaymentsManagerBloc({
    required this.paymentPlannerRepo,
  }) : super(PaymentsManagerInitialState()) {
    _onComputeBudget();
    _onReload();
  }

  final IPaymentPlannerRepo paymentPlannerRepo;
  PaymentPlanner? _lastPlanner;

  void computeBudget(PaymentsManagerEvent event) {
    assert(event is PaymentsManagerComputeBudgetEvent);
    add(event);
  }

  void reload() {
    add(PaymentsManagerEvent.reload());
  }

  void _onReload() {
    on<PaymentsManagerReloadEvent>(
      transformer: restartable(),
      (event, emit) async {
        final id = _lastPlanner?.id;
        if (id != null) {
          add(PaymentsManagerEvent.computeBudget(plannerId: id));
        }
      },
    );
  }

  void _onComputeBudget() {
    on<PaymentsManagerComputeBudgetEvent>(
      transformer: restartable(),
      (event, emit) async {
        final planner = await paymentPlannerRepo.getPlannerById(event.plannerId);
        if (planner != null) {
          final newState = _computeStateFromPlanner(planner);
          _lastPlanner = planner;
          emit(newState);
        }
      },
    );
  }

  PaymentsManagerState _computeStateFromPlanner(PaymentPlanner planner) {
    var targetPlanner = planner.copyWith();
    if (targetPlanner.isDraft) {
      final result = GeneratePlannerUseCase(
        args: GeneratePlannerUseCaseArgs(
          payments: targetPlanner.payments,
          dateStart: targetPlanner.dateStart,
          dateEnd: targetPlanner.dateEnd,
          initialBudget: targetPlanner.initialBudget,
        ),
      ).run();
      targetPlanner = result.planner.copyWith(
        id: targetPlanner.id,
        isDraft: false,
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
    return newState;
  }
}
