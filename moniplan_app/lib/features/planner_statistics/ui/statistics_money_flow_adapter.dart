// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// Адаптер для преобразования данных статистики в формат MoneyFlowUseCaseResult
/// для использования с виджетом MoneyFlowWidget
class StatisticsMoneyFlowAdapter {
  /// Преобразует данные статистики в формат MoneyFlowUseCaseResult
  static MoneyFlowUseCaseResult fromStatistics(BudgetStatistics statistics) {
    // Вычисляем общий доход и расход
    final totalIncome = statistics.incomes.values.fold<num>(0, (sum, value) => sum + value);
    final totalOutcome = statistics.expenses.values.fold<num>(0, (sum, value) => sum + value);

    // Вычисляем начальный и конечный баланс
    final dates = statistics.totalBudget.keys.toList()..sort();

    // Если нет данных, возвращаем пустой результат
    if (dates.isEmpty) {
      return const MoneyFlowUseCaseResult();
    }

    // Берем первое и последнее значение бюджета
    final firstDate = dates.first;
    final lastDate = dates.last;

    final initialBalance = statistics.totalBudget[firstDate]?.totalBudget ?? 0;
    final finalBalance = statistics.totalBudget[lastDate]?.totalBudget ?? 0;

    return MoneyFlowUseCaseResult(
      totalIncome: totalIncome,
      totalOutcome: totalOutcome,
      initialBalance: initialBalance,
      balance: finalBalance,
    );
  }
}
