// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:uuid/uuid.dart';

import '../_index.dart';

/// Анализатор финансовой независимости
///
/// Рассчитывает показатели на пути к финансовой независимости
/// Прогнозирует сроки достижения финансовой свободы
/// Предлагает стратегии ускорения
final class FinancialIndependenceAnalyzer extends CombinedAnalyzer {
  final _uuid = Uuid();

  // Константы для расчетов
  static const _safeWithdrawalRate = 0.04; // 4% безопасная ставка изъятия
  static const _averageInvestmentReturn = 0.07; // 7% средняя доходность инвестиций
  static const _inflationRate = 0.04; // 4% средняя инфляция
  static const _yearsToProject = 30;

  FinancialIndependenceAnalyzer(super.source);

  @override
  AnalysisResult analyze({Map<String, dynamic>? analysisData}) {
    final insights = <Insight>[];

    // Используем геттер для получения только завершенных операций
    final completedOperations = availableOperations;

    // Если недостаточно данных, возвращаем пустой список
    if (completedOperations.isEmpty) {
      return AnalysisResult.empty();
    }

    // Фильтруем доходы и расходы
    final incomeOperations =
        completedOperations.where((op) => op.type == FinancialOperationType.income).toList();

    final expenseOperations =
        completedOperations.where((op) => op.type == FinancialOperationType.expense).toList();

    // Если нет данных о доходах или расходах, возвращаем пустой список
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

    // Рассчитываем среднемесячные доходы и расходы
    // Для простоты предположим, что данные за последние 3 месяца
    final monthlyIncome = totalIncome / 3;
    final monthlyExpenses = totalExpenses / 3;
    final monthlySavings = monthlyIncome - monthlyExpenses;

    // Если расходы превышают доходы, создаем инсайт о необходимости сначала достичь положительного денежного потока
    if (monthlySavings <= 0) {
      insights.add(_createNegativeCashflowInsight(monthlyIncome, monthlyExpenses));
    }

    // 1. Рассчитываем необходимый капитал для финансовой независимости
    final annualExpenses = monthlyExpenses * 12;
    final requiredCapital = annualExpenses / _safeWithdrawalRate;

    // 2. Рассчитываем текущую норму сбережений
    final savingsRate = monthlySavings / monthlyIncome;

    // 3. Оцениваем время до достижения финансовой независимости
    // Предполагаем, что у пользователя уже есть некоторые накопления
    // Для простоты возьмем 10 месячных расходов как приблизительную оценку
    final estimatedCurrentSavings = monthlyExpenses * 10;

    final yearsToFI = _calculateYearsToFI(
      estimatedCurrentSavings,
      annualExpenses,
      monthlySavings * 12,
      _averageInvestmentReturn,
    );

    // 4. Создаем инсайты
    insights.add(_createFITargetInsight(requiredCapital, annualExpenses));
    insights.add(_createTimeToFIInsight(yearsToFI, savingsRate, monthlySavings));
    insights.add(_createAccelerationStrategiesInsight(savingsRate, monthlyExpenses));

    return AnalysisResult(insights: insights, analysisData: analysisData ?? {});
  }

  /// Рассчитывает примерное количество лет до финансовой независимости
  double _calculateYearsToFI(
    double currentSavings,
    double annualExpenses,
    double annualSavings,
    double returnRate,
  ) {
    final targetAmount = annualExpenses / _safeWithdrawalRate;

    // Если текущих сбережений достаточно
    if (currentSavings >= targetAmount) {
      return 0;
    }

    // Простая формула для оценки времени до достижения цели с учетом сложного процента
    // ln(1 + (targetAmount - currentSavings) * returnRate / annualSavings) / ln(1 + returnRate)
    // Но для упрощения используем приближенный расчет

    double years = 0;
    double savings = currentSavings;

    while (savings < targetAmount && years < 100) {
      savings = savings * (1 + returnRate) + annualSavings;
      years += 1;
    }

    return years;
  }

  /// Создает инсайт о целевом капитале для финансовой независимости
  Insight _createFITargetInsight(double requiredCapital, double annualExpenses) {
    return Insight(
      id: _uuid.v4(),
      title: 'Цель финансовой независимости',
      description:
          'Для достижения финансовой независимости тебе потребуется капитал около '
          '${InsightUtils.currencyFormat.format(requiredCapital)}. Эта сумма основана на твоих текущих '
          'годовых расходах (${InsightUtils.currencyFormat.format(annualExpenses)}) и безопасной '
          'ставке изъятия ${(_safeWithdrawalRate * 100).toInt()}%.',
      type: InsightType.goal,
      importance: InsightImportance.medium,
      timeframe: InsightTimeframe.combined,
      additionalData: {
        'requiredCapital': requiredCapital,
        'annualExpenses': annualExpenses,
        'safeWithdrawalRate': _safeWithdrawalRate,
      },
    );
  }

  /// Создает инсайт о времени до достижения финансовой независимости
  Insight _createTimeToFIInsight(double yearsToFI, double savingsRate, double monthlySavings) {
    final savingsRatePercent = (savingsRate * 100).round();

    // Округляем до целого числа лет
    final years = yearsToFI.ceil();

    // Определяем возраст достижения цели (предполагаем средний возраст 35 лет)
    final estimatedAge = 35 + years;

    final description =
        years > 50
            ? 'При текущей норме сбережений ($savingsRatePercent%) достижение финансовой независимости '
                'займет более 50 лет. Рассмотри возможности увеличения дохода или снижения расходов, '
                'чтобы ускорить этот процесс.'
            : 'При текущей норме сбережений ($savingsRatePercent%) и ежемесячных накоплениях '
                '${InsightUtils.currencyFormat.format(monthlySavings)}, ты сможешь достичь финансовой '
                'независимости примерно через $years ${_getYearsWord(years)}, в возрасте около $estimatedAge лет.';

    return Insight(
      id: _uuid.v4(),
      title: 'Путь к финансовой независимости',
      description: description,
      type: InsightType.forecast,
      importance: InsightImportance.medium,
      timeframe: InsightTimeframe.predictive,
      additionalData: {
        'yearsToFI': yearsToFI,
        'savingsRate': savingsRate,
        'monthlySavings': monthlySavings,
        'estimatedAge': estimatedAge,
      },
    );
  }

  /// Создает инсайт о стратегиях ускорения достижения финансовой независимости
  Insight _createAccelerationStrategiesInsight(double savingsRate, double monthlyExpenses) {
    final savingsRatePercent = (savingsRate * 100).round();

    // Рассчитываем, как изменится время до FI при увеличении нормы сбережений
    final targetSavingsRate = min(savingsRate + 0.1, 0.7); // Увеличиваем на 10%, но не более 70%
    final targetSavingsRatePercent = (targetSavingsRate * 100).round();

    // Рассчитываем, сколько нужно сократить расходы
    final expenseReduction = (monthlyExpenses * 0.1); // 10% от текущих расходов

    return Insight(
      id: _uuid.v4(),
      title: 'Стратегии ускорения финансовой независимости',
      description:
          'Увеличение нормы сбережений с $savingsRatePercent% до $targetSavingsRatePercent% '
          'может значительно сократить время до финансовой независимости. Рассмотри возможность '
          'сокращения ежемесячных расходов на ${InsightUtils.currencyFormat.format(expenseReduction)} '
          'или увеличения дохода через дополнительные источники заработка, инвестиции или '
          'развитие карьеры.',
      type: InsightType.advice,
      importance: InsightImportance.medium,
      timeframe: InsightTimeframe.predictive,
      additionalData: {
        'currentSavingsRate': savingsRate,
        'targetSavingsRate': targetSavingsRate,
        'expenseReduction': expenseReduction,
      },
    );
  }

  /// Создает инсайт о необходимости сначала достичь положительного денежного потока
  Insight _createNegativeCashflowInsight(double monthlyIncome, double monthlyExpenses) {
    final deficit = monthlyExpenses - monthlyIncome;

    return Insight(
      id: _uuid.v4(),
      title: 'Первый шаг к финансовой независимости',
      description:
          'Сейчас твои расходы превышают доходы на ${InsightUtils.currencyFormat.format(deficit)} '
          'в месяц. Прежде чем думать о финансовой независимости, важно достичь положительного '
          'денежного потока. Сосредоточься на сокращении расходов или увеличении доходов, '
          'чтобы начать формировать сбережения.',
      type: InsightType.advice,
      importance: InsightImportance.high,
      timeframe: InsightTimeframe.retrospective,
      additionalData: {
        'monthlyIncome': monthlyIncome,
        'monthlyExpenses': monthlyExpenses,
        'monthlyDeficit': deficit,
      },
    );
  }

  /// Возвращает правильное склонение слова "год" в зависимости от числа
  String _getYearsWord(int years) {
    if (years % 10 == 1 && years % 100 != 11) {
      return 'год';
    } else if ([2, 3, 4].contains(years % 10) && ![12, 13, 14].contains(years % 100)) {
      return 'года';
    } else {
      return 'лет';
    }
  }
}
