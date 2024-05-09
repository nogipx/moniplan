import 'package:moniplan_domain/moniplan_domain.dart';

class GeneratePlannerUseCaseArgs {
  final Iterable<Payment> payments;
  final DateTime dateStart;
  final DateTime dateEnd;
  final num initialBudget;

  const GeneratePlannerUseCaseArgs({
    required this.payments,
    required this.dateStart,
    required this.dateEnd,
    this.initialBudget = 0,
  });
}

class GeneratePlannerUseCaseResult {
  final Iterable<Payment> originalPayments;
  final PaymentPlanner planner;

  const GeneratePlannerUseCaseResult({
    required this.originalPayments,
    required this.planner,
  });
}

class GeneratePlannerUseCase implements IUseCase<GeneratePlannerUseCaseResult> {
  final GeneratePlannerUseCaseArgs args;

  const GeneratePlannerUseCase({required this.args});

  @override
  GeneratePlannerUseCaseResult run() {
    const uuid = Uuid();
    final payments = args.payments;

    if (payments.isEmpty) {
      return GeneratePlannerUseCaseResult(
        originalPayments: const [],
        planner: PaymentPlanner(
          id: uuid.v4(),
          dateStart: args.dateStart,
          dateEnd: args.dateEnd,
          initialBudget: args.initialBudget,
          isDraft: false,
        ),
      );
    }

    final dateStart = args.dateStart;
    final dateEnd = args.dateEnd;
    final plannerId = uuid.v4();

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

    return GeneratePlannerUseCaseResult(
      originalPayments: payments,
      planner: PaymentPlanner(
        id: plannerId,
        payments: generated,
        dateStart: dateStart,
        dateEnd: dateEnd,
        initialBudget: args.initialBudget,
        isDraft: false,
      ),
    );
  }
}
