// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import '../_index.dart';

/// Анализатор финансовых коэффициентов
///
/// Рассчитывает ключевые финансовые показатели (сбережения/доход, долг/доход)
/// Сравнивает с рекомендуемыми значениями
/// Предлагает пути улучшения показателей
final class FinancialRatioAnalyzer extends RetrospectiveAnalyzer {
  // Рекомендуемые значения коэффициентов
  static const _recommendedSavingsRatio = 0.2; // 20% от дохода
  static const _maxDebtToIncomeRatio = 0.4; // 40% от дохода
  static const _recommendedEmergencyFundMonths = 3.0; // 3 месяца расходов

  FinancialRatioAnalyzer(super.source);

  @override
  AnalysisResult analyze({Map<String, dynamic>? analysisData}) {
    final insights = <Insight>[];

    // Используем геттер для получения только завершенных операций
    final operations = availableOperations;

    // Если недостаточно данных, возвращаем пустой список
    if (operations.isEmpty) {
      return AnalysisResult.empty();
    }

    // Фильтруем операции по типам
    final incomeOperations =
        operations.where((op) => op.type == FinancialOperationType.income).toList();

    final expenseOperations =
        operations.where((op) => op.type == FinancialOperationType.expense).toList();

    // Если недостаточно данных, возвращаем пустой список
    if (incomeOperations.isEmpty || expenseOperations.isEmpty) {
      return AnalysisResult.empty();
    }

    // Рассчитываем общий доход и расходы
    final totalIncome = incomeOperations.fold<double>(
      0,
      (sum, op) => sum + op.amount.abs().toDouble(),
    );

    final totalExpenses = expenseOperations.fold<double>(
      0,
      (sum, op) => sum + op.amount.abs().toDouble(),
    );

    // 1. Анализ коэффициента сбережений (Savings Ratio)
    final savingsAmount = totalIncome - totalExpenses;
    final savingsRatio = savingsAmount / totalIncome;

    insights.add(_createSavingsRatioInsight(savingsRatio, savingsAmount, totalIncome));

    // 2. Анализ соотношения расходов к доходам (Expense-to-Income Ratio)
    final expenseToIncomeRatio = totalExpenses / totalIncome;

    insights.add(_createExpenseToIncomeInsight(expenseToIncomeRatio, totalExpenses, totalIncome));

    // 3. Оценка резервного фонда (если есть данные о среднемесячных расходах)
    // Для простоты предположим, что данные за последние 3 месяца
    final monthlyExpenses = totalExpenses / 3;

    // Предполагаем, что сбережения могут быть использованы как резервный фонд
    final emergencyFundMonths = savingsAmount / monthlyExpenses;

    insights.add(_createEmergencyFundInsight(emergencyFundMonths, savingsAmount, monthlyExpenses));

    return AnalysisResult(insights: insights, analysisData: analysisData ?? {});
  }

  /// Создает инсайт о коэффициенте сбережений
  Insight _createSavingsRatioInsight(
    double savingsRatio,
    double savingsAmount,
    double totalIncome,
  ) {
    final percentSavings = (savingsRatio * 100).round();
    final recommendedPercent = (_recommendedSavingsRatio * 100).round();

    final isBelowRecommended = savingsRatio < _recommendedSavingsRatio;
    final difference = ((_recommendedSavingsRatio - savingsRatio) * 100).abs().round();

    final title = isBelowRecommended ? 'Низкий уровень сбережений' : 'Хороший уровень сбережений';

    final description =
        isBelowRecommended
            ? 'Ты сберегаешь около $percentSavings% своего дохода, что ниже рекомендуемых $recommendedPercent%. '
                'Попробуй увеличить сбережения на $difference%, чтобы достичь финансовой стабильности.'
            : 'Отличная работа! Ты сберегаешь около $percentSavings% своего дохода, что выше рекомендуемых $recommendedPercent%. '
                'Это хороший задел для достижения финансовых целей и обеспечения стабильности.';

    return createInsight(
      title: title,
      description: description,
      type: InsightType.advice,
      importance: isBelowRecommended ? InsightImportance.high : InsightImportance.medium,
      timeframe: InsightTimeframe.retrospective,
      additionalData: {
        'savingsRatio': savingsRatio,
        'savingsAmount': savingsAmount,
        'totalIncome': totalIncome,
        'recommendedRatio': _recommendedSavingsRatio,
        'isBelowRecommended': isBelowRecommended,
      },
    );
  }

  /// Создает инсайт о соотношении расходов к доходам
  Insight _createExpenseToIncomeInsight(
    double expenseToIncomeRatio,
    double totalExpenses,
    double totalIncome,
  ) {
    final percentExpenses = (expenseToIncomeRatio * 100).round();

    final isHighRatio = expenseToIncomeRatio > 0.8; // 80% и выше считается высоким

    final title = isHighRatio ? 'Высокая доля расходов' : 'Сбалансированные расходы';

    final description =
        isHighRatio
            ? 'Твои расходы составляют около $percentExpenses% от дохода, что оставляет мало места для сбережений. '
                'Рекомендуется снизить это соотношение до 70-80%, чтобы обеспечить финансовую подушку.'
            : 'Твои расходы составляют около $percentExpenses% от дохода, что позволяет формировать сбережения. '
                'Это хороший баланс между текущим потреблением и накоплениями на будущее.';

    return createInsight(
      title: title,
      description: description,
      type: InsightType.advice,
      importance: isHighRatio ? InsightImportance.medium : InsightImportance.low,
      timeframe: InsightTimeframe.retrospective,
      additionalData: {
        'expenseToIncomeRatio': expenseToIncomeRatio,
        'totalExpenses': totalExpenses,
        'totalIncome': totalIncome,
        'isHighRatio': isHighRatio,
      },
    );
  }

  /// Создает инсайт о резервном фонде
  Insight _createEmergencyFundInsight(
    double emergencyFundMonths,
    double savingsAmount,
    double monthlyExpenses,
  ) {
    final isBelowRecommended = emergencyFundMonths < _recommendedEmergencyFundMonths;

    final title =
        isBelowRecommended ? 'Недостаточный резервный фонд' : 'Достаточный резервный фонд';

    final roundedMonths = emergencyFundMonths.toStringAsFixed(1);
    final neededAmount = (_recommendedEmergencyFundMonths * monthlyExpenses) - savingsAmount;

    final description =
        isBelowRecommended
            ? 'Твоих сбережений хватит примерно на $roundedMonths месяцев расходов, что меньше рекомендуемых $_recommendedEmergencyFundMonths месяцев. '
                'Для создания надежного резервного фонда рекомендуется дополнительно накопить около ${InsightUtils.currencyFormat.format(neededAmount)}.'
            : 'Твоих сбережений хватит примерно на $roundedMonths месяцев расходов, что соответствует или превышает рекомендуемые $_recommendedEmergencyFundMonths месяца. '
                'У тебя есть хорошая финансовая подушка безопасности на случай непредвиденных ситуаций.';

    return createInsight(
      title: title,
      description: description,
      type: InsightType.advice,
      importance: isBelowRecommended ? InsightImportance.high : InsightImportance.low,
      timeframe: InsightTimeframe.retrospective,
      additionalData: {
        'emergencyFundMonths': emergencyFundMonths,
        'savingsAmount': savingsAmount,
        'monthlyExpenses': monthlyExpenses,
        'recommendedMonths': _recommendedEmergencyFundMonths,
        'neededAdditionalAmount': neededAmount,
        'isBelowRecommended': isBelowRecommended,
      },
    );
  }
}
