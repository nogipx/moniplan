// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: prefer_collection_literals

import 'dart:collection';

import 'package:moniplan_app/domain/lib/moniplan_domain.dart';

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

    num lastUpdatedBudget = initialBudget;

    // Сначала группируем платежи по дате
    final paymentsByDate = <DateTime, List<Payment>>{};
    for (final payment in payments) {
      paymentsByDate.putIfAbsent(payment.date.dayBound, () => []).add(payment);
    }

    // Сортируем даты
    final sortedDates = paymentsByDate.keys.toList()..sort();

    // Создаем список платежей в правильном порядке
    final sortedPayments = <Payment>[];
    for (final date in sortedDates) {
      // Для каждой даты сортируем платежи с помощью SortPaymentsUsecase
      // Это обеспечит единый порядок платежей во всем приложении
      final paymentsForDate = SortPaymentsUsecase(payments: paymentsByDate[date]!).run();

      sortedPayments.addAll(paymentsForDate);
    }

    for (final item in sortedPayments) {
      // Учитываем платежи в зависимости от их статуса и типа
      // Если платеж выключен (isEnabled == false), не учитываем его в расчете
      // Если платеж включен (isEnabled == true), учитываем его
      final shouldCountInBudget = item.isEnabled;

      // Для коррекции устанавливаем баланс равным значению amount
      if (item.type == PaymentType.correction && shouldCountInBudget) {
        tempBudget = item.details.money;
      } else {
        // Для обычных платежей прибавляем/вычитаем сумму
        final value = shouldCountInBudget ? item.normalizedMoney : 0;
        tempBudget += value;
      }

      budget[item] = tempBudget;

      // Обновляем lastUpdatedBudget только для текущих и прошедших дат
      if (item.date.compareTo(now) <= 0) {
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
