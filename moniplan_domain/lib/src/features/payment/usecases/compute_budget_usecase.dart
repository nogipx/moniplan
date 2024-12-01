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
    final now = DateTime.now().dayBound;

    var tempBudget = initialBudget;

    num lastUpdatedBudget = 0;
    bool shouldIncludeCurrent = true;

    for (final item in payments) {
      final value = item.isEnabled ? item.normalizedMoney : 0;

      tempBudget += value;
      budget[item] = tempBudget;

      if (item.date.isAfter(now)) {
        shouldIncludeCurrent = false;
      }

      if (shouldIncludeCurrent) {
        lastUpdatedBudget = tempBudget;
      }
    }

    final result = ComputeBudgetUseCaseResult(
      budget: budget,
      lastUpdatedBudget: lastUpdatedBudget,
    );

    return result;
  }
}

class ComputeBudgetUseCaseResult {
  final LinkedHashMap<Payment, num> budget;
  final num lastUpdatedBudget;

  const ComputeBudgetUseCaseResult({
    required this.budget,
    this.lastUpdatedBudget = 0,
  });
}
