// ignore_for_file: prefer_collection_literals

import 'dart:collection';

import 'package:moniplan_core/moniplan_core.dart';

import '../../_common/usecases/_usecase.dart';

class ComputeBudgetUseCaseArgs {
  final double initialBudget;
  final Iterable<Payment> payments;
  final DateTime startPeriod;
  final DateTime endPeriod;

  const ComputeBudgetUseCaseArgs({
    this.initialBudget = 0,
    required this.payments,
    required this.startPeriod,
    required this.endPeriod,
  });
}

class ComputeBudgetUseCaseResult {
  final Iterable<Payment> paymentsOriginal;
  final Iterable<Payment> paymentsGenerated;
  final LinkedHashMap<Payment, double> mediateBudget;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  const ComputeBudgetUseCaseResult({
    required this.mediateBudget,
    this.paymentsOriginal = const [],
    this.paymentsGenerated = const [],
    this.dateStart,
    this.dateEnd,
  });
}

class ComputeBudgetUseCase extends UseCase<ComputeBudgetUseCaseResult> {
  final ComputeBudgetUseCaseArgs args;

  const ComputeBudgetUseCase({
    required this.args,
  });

  @override
  ComputeBudgetUseCaseResult run() {
    final payments = args.payments;

    if (payments.isEmpty) {
      throw Exception('Payments list is empty');
    }

    final dateStart = args.startPeriod;
    final dateEnd = args.endPeriod;

    final allPayments = payments
        .map(
          (e) => GenerateRepeatPaymentsUseCase(
            payment: e,
            startPeriod: dateStart,
            endPeriod: dateEnd,
          ).run().payments,
        )
        .expand((e) => e)
        .toList();

    final paymentsId = allPayments.map((e) => e.id).toSet();
    if (paymentsId.length != allPayments.length) {
      throw Exception('There are duplicates payment ids');
    }

    allPayments.sort((a, b) => a.date.compareTo(b.date));

    final budget = LinkedHashMap<Payment, double>();

    var tempBudget = args.initialBudget;
    for (final item in allPayments) {
      tempBudget += item.enabled ? item.normalizedMoney : 0;
      budget[item] = tempBudget;
    }

    final result = ComputeBudgetUseCaseResult(
      paymentsOriginal: payments,
      paymentsGenerated: budget.keys,
      mediateBudget: budget,
      dateStart: dateStart,
      dateEnd: dateEnd,
    );

    return result;
  }
}
