// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/src/features/insights/interfaces/i_financial_analyzer.dart';
import 'package:moniplan_domain/src/features/insights/interfaces/i_financial_data.dart';
import 'package:moniplan_domain/src/features/insights/models/_index.dart';
import 'package:moniplan_domain/src/features/insights/utils/insight_utils.dart';

/// Анализатор для предиктивных инсайтов
final class PredictiveAnalyzerImpl extends PredictiveAnalyzer {
  PredictiveAnalyzerImpl(super.source);

  @override
  AnalysisResult analyze({Map<String, dynamic>? analysisData}) {
    final insights = <Insight>[];
    final operations = availableOperations;
    // Фильтруем только запланированные операции
    final plannedOperations =
        operations.where((op) => op.status == FinancialOperationStatus.planned).toList();

    if (plannedOperations.isEmpty) {
      return AnalysisResult.empty();
    }

    // 1. Прогноз бюджета на основе запланированных операций
    insights.addAll(_analyzeBudgetForecast(source, plannedOperations, analysisData));

    // Все инсайты из этого метода относятся к прогностическому анализу
    return AnalysisResult(
      insights: InsightUtils.setTimeframeForAll(insights, InsightTimeframe.predictive),
      analysisData: analysisData ?? {},
    );
  }

  /// Анализирует прогноз бюджета на основе запланированных операций
  List<Insight> _analyzeBudgetForecast(
    IFinancialSource source,
    List<IFinancialData> plannedOperations,
    Map<String, dynamic>? analysisData,
  ) {
    final insights = <Insight>[];

    // Рассчитываем общую сумму запланированных доходов и расходов
    final plannedExpenses = plannedOperations
        .where((op) => op.type == FinancialOperationType.expense)
        .fold<double>(0, (sum, op) => sum + op.amount.toDouble());

    final plannedIncomes = plannedOperations
        .where((op) => op.type == FinancialOperationType.income)
        .fold<double>(0, (sum, op) => sum + op.amount.toDouble());

    // Рассчитываем баланс
    final plannedBalance = plannedIncomes - plannedExpenses;

    // Если у нас есть данные о ежедневных расходах из ретроспективного анализа,
    // используем их для более точного прогноза
    if (analysisData != null && analysisData.containsKey('dailyTotals')) {
      final dailyTotals = analysisData['dailyTotals'] as Map<DateTime, double>;

      if (dailyTotals.isNotEmpty) {
        // Рассчитываем средний ежедневный расход
        final avgDailyExpense = dailyTotals.values.reduce((a, b) => a + b) / dailyTotals.length;

        // Рассчитываем количество дней до конца периода
        final today = DateTime.now();
        final endDate = source.endDate ?? today.add(const Duration(days: 30));
        final daysLeft = endDate.difference(today).inDays;

        // Прогнозируем дополнительные расходы на основе среднего ежедневного расхода
        final projectedAdditionalExpenses = avgDailyExpense * daysLeft;

        // Рассчитываем итоговый прогнозируемый баланс
        final projectedBalance = plannedBalance - projectedAdditionalExpenses;

        // Создаем инсайт о прогнозируемом балансе
        final isNegative = projectedBalance < 0;

        insights.add(
          createInsight(
            title: isNegative ? 'Возможный дефицит бюджета' : 'Прогноз остатка бюджета',
            description:
                isNegative
                    ? 'На основе твоих средних ежедневных расходов (${InsightUtils.currencyFormat.format(avgDailyExpense)} в день) '
                        'и запланированных операций, к концу периода может возникнуть дефицит в размере '
                        '${InsightUtils.currencyFormat.format(projectedBalance.abs())}. '
                        'Рекомендую пересмотреть планируемые расходы или увеличить доходы.'
                    : 'По моим расчетам, с учетом средних ежедневных расходов и запланированных операций, '
                        'к концу периода у тебя останется примерно ${InsightUtils.currencyFormat.format(projectedBalance)}. '
                        'Это хороший запас!',
            type: isNegative ? InsightType.forecast : InsightType.advice,
            importance:
                isNegative
                    ? (projectedBalance < -plannedIncomes * 0.5
                        ? InsightImportance.critical
                        : InsightImportance.high)
                    : InsightImportance.medium,
            additionalData: {
              'plannedExpenses': plannedExpenses,
              'plannedIncomes': plannedIncomes,
              'plannedBalance': plannedBalance,
              'avgDailyExpense': avgDailyExpense,
              'daysLeft': daysLeft,
              'projectedAdditionalExpenses': projectedAdditionalExpenses,
              'projectedBalance': projectedBalance,
            },
          ),
        );
      }
    } else {
      // Если нет данных о ежедневных расходах, создаем более простой инсайт
      final isNegative = plannedBalance < 0;

      insights.add(
        createInsight(
          title: isNegative ? 'Запланирован дефицит бюджета' : 'Запланирован профицит бюджета',
          description:
              isNegative
                  ? 'Сумма запланированных расходов (${InsightUtils.currencyFormat.format(plannedExpenses)}) '
                      'превышает сумму запланированных доходов (${InsightUtils.currencyFormat.format(plannedIncomes)}) '
                      'на ${InsightUtils.currencyFormat.format(plannedBalance.abs())}. '
                      'Рекомендую пересмотреть планируемые расходы или увеличить доходы.'
                  : 'Сумма запланированных доходов (${InsightUtils.currencyFormat.format(plannedIncomes)}) '
                      'превышает сумму запланированных расходов (${InsightUtils.currencyFormat.format(plannedExpenses)}) '
                      'на ${InsightUtils.currencyFormat.format(plannedBalance)}. '
                      'Это хороший запас!',
          type: isNegative ? InsightType.forecast : InsightType.advice,
          importance:
              isNegative
                  ? (plannedBalance < -plannedIncomes * 0.5
                      ? InsightImportance.high
                      : InsightImportance.medium)
                  : InsightImportance.low,
          additionalData: {
            'plannedExpenses': plannedExpenses,
            'plannedIncomes': plannedIncomes,
            'plannedBalance': plannedBalance,
          },
        ),
      );
    }

    return insights;
  }
}
