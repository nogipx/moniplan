// ignore_for_file: prefer_collection_literals

import 'dart:collection';

import 'package:moniplan_domain/moniplan_domain.dart';

/// Вычисляет промежуточные итоги платежей.
/// Работает с любым списком платежей, не зависит от генерации планера.
class ComputeBudgetUseCase implements IUseCase<ComputeBudgetUseCaseResult> {
  final num initialBudget;
  final Iterable<Payment> payments;

  const ComputeBudgetUseCase({
    this.initialBudget = 0,
    required this.payments,
  });

  @override
  ComputeBudgetUseCaseResult run() {
    final budget = LinkedHashMap<Payment, num>();

    var tempBudget = initialBudget;
    for (final item in payments) {
      tempBudget += item.isEnabled ? item.normalizedMoney : 0;
      budget[item] = tempBudget;
    }

    final result = ComputeBudgetUseCaseResult(
      budget: budget,
    );

    return result;
  }
}

class ComputeBudgetUseCaseResult {
  final LinkedHashMap<Payment, num> budget;

  const ComputeBudgetUseCaseResult({
    required this.budget,
  });
}
