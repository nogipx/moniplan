// ignore_for_file: prefer_collection_literals

import 'dart:collection';

import 'package:moniplan_domain/moniplan_domain.dart';

class ComputeBudgetUseCaseArgs {
  final num initialBudget;
  final Iterable<Payment> payments;

  const ComputeBudgetUseCaseArgs({
    this.initialBudget = 0,
    required this.payments,
  });
}

class ComputeBudgetUseCaseResult {
  final LinkedHashMap<Payment, num> budget;

  const ComputeBudgetUseCaseResult({
    required this.budget,
  });
}

class ComputeBudgetUseCase implements IUseCase<ComputeBudgetUseCaseResult> {
  final ComputeBudgetUseCaseArgs args;

  const ComputeBudgetUseCase({
    required this.args,
  });

  @override
  ComputeBudgetUseCaseResult run() {
    final budget = LinkedHashMap<Payment, num>();

    var tempBudget = args.initialBudget;
    for (final item in args.payments) {
      tempBudget += item.isEnabled ? item.normalizedMoney : 0;
      budget[item] = tempBudget;
    }

    final result = ComputeBudgetUseCaseResult(
      budget: budget,
    );

    return result;
  }
}
