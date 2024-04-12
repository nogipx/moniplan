import 'package:moniplan_domain/moniplan_domain.dart';

class GeneratePlannerUseCaseArgs {
  final Iterable<Payment> payments;
  final DateTime startPeriod;
  final DateTime endPeriod;

  const GeneratePlannerUseCaseArgs({
    required this.payments,
    required this.startPeriod,
    required this.endPeriod,
  });
}

class GeneratePlannerUseCaseResult {
  final Iterable<Payment> originalPayments;
  final Iterable<Payment> generatedPayments;
  final DateTime startPeriod;
  final DateTime endPeriod;

  const GeneratePlannerUseCaseResult({
    required this.originalPayments,
    required this.generatedPayments,
    required this.startPeriod,
    required this.endPeriod,
  });
}

class GeneratePlannerUseCase implements UseCase<GeneratePlannerUseCaseResult> {
  final GeneratePlannerUseCaseArgs args;

  const GeneratePlannerUseCase({required this.args});

  @override
  GeneratePlannerUseCaseResult run() {
    final payments = args.payments;

    if (payments.isEmpty) {
      return GeneratePlannerUseCaseResult(
        originalPayments: const [],
        generatedPayments: const [],
        startPeriod: args.startPeriod,
        endPeriod: args.endPeriod,
      );
    }

    final dateStart = args.startPeriod;
    final dateEnd = args.endPeriod;

    final generated = payments
        .map(
          (e) => GenerateRepeatPaymentsUseCase(
            payment: e,
            startPeriod: dateStart,
            endPeriod: dateEnd,
          ).run().payments,
        )
        .expand((e) => e)
        .toList();

    final paymentsId = generated.map((e) => e.id).toSet();
    if (paymentsId.length != generated.length) {
      throw Exception('There are duplicates payment ids');
    }

    generated.sort((a, b) => a.date.compareTo(b.date));

    return GeneratePlannerUseCaseResult(
      originalPayments: payments,
      generatedPayments: generated,
      startPeriod: args.startPeriod,
      endPeriod: args.endPeriod,
    );
  }
}
