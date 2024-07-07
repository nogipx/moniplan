import 'package:moniplan_domain/moniplan_domain.dart';

class GenerateNewPlannerUseCaseArgs {
  final String? customPlannerId;
  final Iterable<Payment> payments;
  final DateTime dateStart;
  final DateTime dateEnd;
  final num initialBudget;

  const GenerateNewPlannerUseCaseArgs({
    required this.payments,
    required this.dateStart,
    required this.dateEnd,
    this.initialBudget = 0,
    this.customPlannerId,
  });
}

class GenerateNewPlannerUseCaseResult {
  final Iterable<Payment> originalPayments;
  final PaymentPlanner planner;

  const GenerateNewPlannerUseCaseResult({
    required this.originalPayments,
    required this.planner,
  });
}

class GenerateNewPlannerUseCase implements IUseCase<GenerateNewPlannerUseCaseResult> {
  final GenerateNewPlannerUseCaseArgs args;

  const GenerateNewPlannerUseCase({required this.args});

  @override
  GenerateNewPlannerUseCaseResult run() {
    const uuid = Uuid();
    final payments = args.payments;

    if (payments.isEmpty) {
      return GenerateNewPlannerUseCaseResult(
        originalPayments: const [],
        planner: PaymentPlanner(
          id: '',
          dateStart: args.dateStart,
          dateEnd: args.dateEnd,
          initialBudget: args.initialBudget,
          isGenerationAllowed: false,
        ),
      );
    }

    final dateStart = args.dateStart;
    final dateEnd = args.dateEnd;
    final plannerId = args.customPlannerId ?? uuid.v4();

    final generated = payments
        .map(
          (e) => ExpandPaymentToPeriodUseCase(
            payment: e,
            startPeriod: dateStart,
            endPeriod: dateEnd,
            plannerId: plannerId,
          ).run().payments,
        )
        .expand((e) => e)
        .toList();

    final paymentsId = generated.map((e) => e.paymentId).toSet();
    if (paymentsId.length != generated.length) {
      throw Exception('There are duplicates payment ids');
    }

    generated.sort((a, b) => a.date.compareTo(b.date));

    final resultPlanner = PaymentPlanner(
      id: plannerId,
      payments: generated,
      dateStart: dateStart,
      dateEnd: dateEnd,
      initialBudget: args.initialBudget,
      isGenerationAllowed: false,
    );

    return GenerateNewPlannerUseCaseResult(
      originalPayments: payments,
      planner: resultPlanner,
    );
  }
}
