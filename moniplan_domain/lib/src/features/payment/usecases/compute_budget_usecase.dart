// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: prefer_collection_literals

import 'dart:collection';

import 'package:moniplan_domain/moniplan_domain.dart';

/// Вычисляет промежуточные итоги платежей.
/// Работает с любым списком платежей, не зависит от генерации планера.
class ComputeBudgetUseCase implements IUseCase<ComputeBudgetUseCaseResult> {
  final num initialBudget;
  final Iterable<Payment> payments;

  const ComputeBudgetUseCase({this.initialBudget = 0, required this.payments});

  @override
  ComputeBudgetUseCaseResult run() {
    final budget = LinkedHashMap<Payment, num>();
    final now = DateTime.now().dayBound;

    var tempBudget = initialBudget;

    num lastUpdatedBudget = 0;
    bool shouldIncludeCurrent = true;

    // Сортируем платежи по дате и статусу выполнения
    final sortedPayments = List<Payment>.from(payments);
    sortedPayments.sort((a, b) {
      // Сначала сортируем по дате
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) {
        return dateComparison;
      }

      // Если даты одинаковые, сортируем по статусу выполнения
      // Выполненные платежи идут первыми в рамках одного дня
      if (a.isDone != b.isDone) {
        return a.isDone ? -1 : 1;
      }

      // Если и статусы выполнения одинаковые, сортируем по типу платежа
      if (a.type != b.type) {
        return a.type == PaymentType.income ? -1 : 1;
      }

      // Наконец, сортируем по сумме (от большей к меньшей)
      return b.normalizedMoney.abs().compareTo(a.normalizedMoney.abs());
    });

    for (final item in sortedPayments) {
      // Учитываем только активные платежи при расчете бюджета
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

    final result = ComputeBudgetUseCaseResult(budget: budget, lastUpdatedBudget: lastUpdatedBudget);

    return result;
  }
}

class ComputeBudgetUseCaseResult {
  final LinkedHashMap<Payment, num> budget;
  final num lastUpdatedBudget;

  const ComputeBudgetUseCaseResult({required this.budget, this.lastUpdatedBudget = 0});
}
