// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// Генерирует планер, добавляя в него повторяющиеся операции.
class GenerateNewPlannerUseCase implements IUseCase<GenerateNewPlannerUseCaseResult> {
  final String? customPlannerId;
  final Iterable<Payment> payments;
  final DateTime dateStart;
  final DateTime dateEnd;
  final num initialBudget;

  const GenerateNewPlannerUseCase({
    required this.payments,
    required this.dateStart,
    required this.dateEnd,
    this.initialBudget = 0,
    this.customPlannerId,
  });

  @override
  GenerateNewPlannerUseCaseResult run() {
    const uuid = Uuid();

    if (payments.isEmpty) {
      final emptyPlanner = Planner(
        id: customPlannerId ?? uuid.v4(),
        payments: [],
        dateStart: dateStart,
        dateEnd: dateEnd,
        initialBudget: initialBudget,
        isGenerationAllowed: false,
      );
      return GenerateNewPlannerUseCaseResult(
        originalPayments: payments,
        planner: emptyPlanner,
      );
    }

    final plannerId = customPlannerId ?? uuid.v4();

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

    final resultPlanner = Planner(
      id: plannerId,
      payments: generated,
      dateStart: dateStart,
      dateEnd: dateEnd,
      initialBudget: initialBudget,
      isGenerationAllowed: false,
    );

    return GenerateNewPlannerUseCaseResult(
      originalPayments: payments,
      planner: resultPlanner,
    );
  }
}

class GenerateNewPlannerUseCaseResult {
  final Iterable<Payment> originalPayments;
  final Planner planner;

  const GenerateNewPlannerUseCaseResult({
    required this.originalPayments,
    required this.planner,
  });
}
