// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:collection/collection.dart';

import '../_index.dart';

/// Анализатор для оптимизации бюджета
///
/// Использует алгоритмы оптимизации для выявления возможностей экономии
/// и более эффективного распределения средств
final class BudgetOptimizationAnalyzer extends CombinedAnalyzer {
  BudgetOptimizationAnalyzer(super.source);

  // Минимальный процент экономии, который считается значимым
  static const _minSavingsPercent = 5;

  // Минимальная сумма экономии, которая считается значимой
  static const _minSavingsAmount = 1000.0;

  @override
  AnalysisResult analyze({Map<String, dynamic>? analysisData}) {
    final insights = <Insight>[];
    final completedOperations =
        availableOperations.where((op) => op.status == FinancialOperationStatus.completed).toList();
    final plannedOperations =
        availableOperations.where((op) => op.status == FinancialOperationStatus.planned).toList();

    // Если нет завершенных операций, возвращаем пустой список
    if (completedOperations.isEmpty) {
      return AnalysisResult.empty();
    }

    // 1. Анализ повторяющихся расходов и поиск возможностей для оптимизации
    insights.addAll(_analyzeRecurringExpenses(completedOperations));

    // 2. Анализ категорий с избыточными расходами
    insights.addAll(_analyzeOverspendingCategories(completedOperations));

    // 3. Анализ возможностей для оптимизации на основе сравнения с запланированными операциями
    if (plannedOperations.isNotEmpty) {
      insights.addAll(_analyzeActualVsPlanned(completedOperations, plannedOperations));
    }

    // 4. Анализ возможностей для оптимизации на основе сезонных паттернов
    insights.addAll(_analyzeSeasonalOptimization(completedOperations));

    return AnalysisResult(insights: insights, analysisData: analysisData ?? {});
  }

  /// Анализирует повторяющиеся расходы и ищет возможности для оптимизации
  List<Insight> _analyzeRecurringExpenses(List<IFinancialData> operations) {
    final insights = <Insight>[];

    // Фильтруем только расходы
    final expenses = operations.where((op) => op.type == FinancialOperationType.expense).toList();

    if (expenses.isEmpty) {
      return insights;
    }

    // Группируем расходы по категориям
    final expensesByCategory = <String, List<IFinancialData>>{};
    for (final expense in expenses) {
      final category = expense.category.isNotEmpty ? expense.category : 'Без категории';
      expensesByCategory[category] = [...(expensesByCategory[category] ?? []), expense];
    }

    // Находим категории с повторяющимися расходами
    final recurringCategories = <String, List<IFinancialData>>{};

    for (final entry in expensesByCategory.entries) {
      final category = entry.key;
      final categoryExpenses = entry.value;

      // Если в категории менее 3 расходов, пропускаем
      if (categoryExpenses.length < 3) {
        continue;
      }

      // Группируем расходы по месяцам
      final expensesByMonth = <String, List<IFinancialData>>{};
      for (final expense in categoryExpenses) {
        final monthKey = '${expense.date.year}-${expense.date.month}';
        expensesByMonth[monthKey] = [...(expensesByMonth[monthKey] ?? []), expense];
      }

      // Если расходы есть минимум в 3 разных месяцах, считаем категорию повторяющейся
      if (expensesByMonth.length >= 3) {
        recurringCategories[category] = categoryExpenses;
      }
    }

    // Анализируем каждую повторяющуюся категорию
    for (final entry in recurringCategories.entries) {
      final category = entry.key;
      final categoryExpenses = entry.value;

      // Рассчитываем среднюю сумму расходов в категории
      final totalAmount = categoryExpenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount.toDouble(),
      );
      final avgAmount = totalAmount / categoryExpenses.length;

      // Находим расходы, которые значительно выше среднего (на 30% и более)
      final highExpenses =
          categoryExpenses.where((expense) => expense.amount > avgAmount * 1.3).toList();

      if (highExpenses.isNotEmpty) {
        // Рассчитываем потенциальную экономию
        final actualTotal = categoryExpenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount.toDouble(),
        );

        // Предполагаем, что все высокие расходы можно снизить до среднего уровня
        final optimizedTotal = categoryExpenses.fold<double>(
          0,
          (sum, expense) =>
              sum + (expense.amount > avgAmount * 1.3 ? avgAmount : expense.amount.toDouble()),
        );

        final potentialSavings = actualTotal - optimizedTotal;
        final savingsPercent = (potentialSavings / actualTotal * 100).round();

        // Если потенциальная экономия значительна
        if (savingsPercent >= _minSavingsPercent && potentialSavings >= _minSavingsAmount) {
          // Получаем оригинальные платежи с помощью сервиса
          final relatedPayments = PaymentExtractionService.extractPayments(highExpenses);

          insights.add(
            createInsight(
              title: 'Возможность оптимизации расходов на $category',
              description:
                  'Я обнаружил, что твои расходы на $category иногда значительно выше обычного. '
                  'Если бы ты оптимизировал эти расходы до среднего уровня, то мог бы сэкономить '
                  'около ${InsightUtils.currencyFormat.format(potentialSavings)} (примерно $savingsPercent% от общих расходов в этой категории). '
                  'Возможно, стоит проанализировать, почему некоторые платежи значительно выше других, '
                  'и найти способы снизить эти пиковые расходы.',
              type: InsightType.optimization,
              importance: savingsPercent > 15 ? InsightImportance.high : InsightImportance.medium,
              timeframe: InsightTimeframe.combined,
              relatedPayments: relatedPayments,
              additionalData: {
                'category': category,
                'avgAmount': avgAmount,
                'actualTotal': actualTotal,
                'optimizedTotal': optimizedTotal,
                'potentialSavings': potentialSavings,
                'savingsPercent': savingsPercent,
                'highExpenses':
                    highExpenses
                        .map(
                          (e) => {
                            'date': e.date.toIso8601String(),
                            'amount': e.amount,
                            'percentAboveAvg': ((e.amount / avgAmount - 1) * 100).round(),
                          },
                        )
                        .toList(),
              },
            ),
          );
        }
      }
    }

    return insights;
  }

  /// Анализирует категории с избыточными расходами
  List<Insight> _analyzeOverspendingCategories(List<IFinancialData> operations) {
    final insights = <Insight>[];

    // Фильтруем только расходы
    final expenses = operations.where((op) => op.type == FinancialOperationType.expense).toList();

    if (expenses.isEmpty) {
      return insights;
    }

    // Группируем расходы по категориям
    final expensesByCategory = <String, List<IFinancialData>>{};
    for (final expense in expenses) {
      final category = expense.category.isNotEmpty ? expense.category : 'Без категории';
      expensesByCategory[category] = [...(expensesByCategory[category] ?? []), expense];
    }

    // Рассчитываем общую сумму расходов
    final totalExpenses = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount.toDouble(),
    );

    // Рассчитываем суммы расходов по категориям и их процент от общих расходов
    final categoryTotals = <String, double>{};
    final categoryPercents = <String, double>{};

    for (final entry in expensesByCategory.entries) {
      final category = entry.key;
      final categoryExpenses = entry.value;

      final categoryTotal = categoryExpenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount.toDouble(),
      );

      categoryTotals[category] = categoryTotal;
      categoryPercents[category] = categoryTotal / totalExpenses * 100;
    }

    // Находим категории с высоким процентом расходов (более 25%)
    final highPercentCategories =
        categoryPercents.entries.where((entry) => entry.value >= 25).toList();

    for (final entry in highPercentCategories) {
      final category = entry.key;
      final percent = entry.value.round();
      final categoryExpenses = expensesByCategory[category] ?? [];

      // Получаем оригинальные платежи с помощью сервиса
      final relatedPayments = PaymentExtractionService.extractPayments(categoryExpenses);

      // Анализируем подкатегории или конкретные расходы
      final subCategoryAnalysis = _analyzeSubCategories(categoryExpenses);

      insights.add(
        createInsight(
          title: 'Высокая доля расходов на $category',
          description:
              'Я заметил, что $percent% твоих расходов приходится на категорию "$category". '
              'Это значительная часть твоего бюджета. ${subCategoryAnalysis.isNotEmpty ? 'Особенно выделяются расходы на: ${subCategoryAnalysis.take(2).map((e) => "${e['name']} (${e['percent']}%)").join(', ')}. ' : ''}'
              'Возможно, стоит пересмотреть эти расходы и найти способы их оптимизации. '
              'Даже небольшое сокращение в этой категории может дать значительную экономию.',
          type: InsightType.optimization,
          importance: percent > 40 ? InsightImportance.high : InsightImportance.medium,
          timeframe: InsightTimeframe.combined,
          relatedPayments: relatedPayments,
          additionalData: {
            'category': category,
            'percent': percent,
            'total': categoryTotals[category],
            'subCategories': subCategoryAnalysis,
          },
        ),
      );
    }

    return insights;
  }

  /// Анализирует подкатегории расходов
  List<Map<String, dynamic>> _analyzeSubCategories(List<IFinancialData> expenses) {
    // Если в дополнительных данных есть информация о подкатегориях
    final subCategoryCounts = <String, double>{};

    for (final expense in expenses) {
      if (expense.additionalData != null && expense.additionalData!['subCategory'] != null) {
        final subCategory = expense.additionalData!['subCategory'] as String;
        subCategoryCounts[subCategory] =
            (subCategoryCounts[subCategory] ?? 0) + expense.amount.toDouble();
      }
    }

    // Если подкатегорий нет, группируем по описанию или другим признакам
    if (subCategoryCounts.isEmpty) {
      final descriptionCounts = <String, double>{};

      for (final expense in expenses) {
        String key = 'Прочее';

        if (expense.additionalData != null) {
          if (expense.additionalData!['description'] != null) {
            key = expense.additionalData!['description'] as String;
          } else if (expense.additionalData!['merchant'] != null) {
            key = expense.additionalData!['merchant'] as String;
          }
        }

        descriptionCounts[key] = (descriptionCounts[key] ?? 0) + expense.amount.toDouble();
      }

      // Объединяем мелкие расходы в категорию "Прочее"
      final totalAmount = descriptionCounts.values.sum;
      final significantDescriptions = <String, double>{};
      double otherTotal = 0;

      for (final entry in descriptionCounts.entries) {
        if (entry.value / totalAmount >= 0.05) {
          significantDescriptions[entry.key] = entry.value;
        } else {
          otherTotal += entry.value;
        }
      }

      if (otherTotal > 0) {
        significantDescriptions['Прочее'] = otherTotal;
      }

      // Сортируем по убыванию суммы
      final sortedEntries =
          significantDescriptions.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      return sortedEntries
          .map(
            (e) => {
              'name': e.key,
              'amount': e.value,
              'percent': ((e.value / totalAmount) * 100).round(),
            },
          )
          .toList();
    }

    // Сортируем подкатегории по убыванию суммы
    final totalAmount = subCategoryCounts.values.sum;
    final sortedEntries =
        subCategoryCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
        .map(
          (e) => {
            'name': e.key,
            'amount': e.value,
            'percent': ((e.value / totalAmount) * 100).round(),
          },
        )
        .toList();
  }

  /// Анализирует фактические расходы в сравнении с запланированными
  List<Insight> _analyzeActualVsPlanned(
    List<IFinancialData> completedOperations,
    List<IFinancialData> plannedOperations,
  ) {
    final insights = <Insight>[];

    // Фильтруем только расходы
    final completedExpenses =
        completedOperations.where((op) => op.type == FinancialOperationType.expense).toList();

    final plannedExpenses =
        plannedOperations.where((op) => op.type == FinancialOperationType.expense).toList();

    if (completedExpenses.isEmpty || plannedExpenses.isEmpty) {
      return insights;
    }

    // Группируем расходы по категориям
    final completedByCategory = <String, List<IFinancialData>>{};
    for (final expense in completedExpenses) {
      final category = expense.category.isNotEmpty ? expense.category : 'Без категории';
      completedByCategory[category] = [...(completedByCategory[category] ?? []), expense];
    }

    final plannedByCategory = <String, List<IFinancialData>>{};
    for (final expense in plannedExpenses) {
      final category = expense.category.isNotEmpty ? expense.category : 'Без категории';
      plannedByCategory[category] = [...(plannedByCategory[category] ?? []), expense];
    }

    // Рассчитываем суммы расходов по категориям
    final completedTotals = <String, double>{};
    for (final entry in completedByCategory.entries) {
      completedTotals[entry.key] = entry.value.fold<double>(
        0,
        (sum, expense) => sum + expense.amount.toDouble(),
      );
    }

    final plannedTotals = <String, double>{};
    for (final entry in plannedByCategory.entries) {
      plannedTotals[entry.key] = entry.value.fold<double>(
        0,
        (sum, expense) => sum + expense.amount.toDouble(),
      );
    }

    // Находим категории, где фактические расходы значительно превышают запланированные
    final overBudgetCategories = <String, double>{};

    for (final entry in completedTotals.entries) {
      final category = entry.key;
      final completedTotal = entry.value;
      final plannedTotal = plannedTotals[category] ?? 0;

      if (plannedTotal > 0 && completedTotal > plannedTotal * 1.2) {
        overBudgetCategories[category] = completedTotal - plannedTotal;
      }
    }

    // Если есть категории с перерасходом, создаем инсайт
    if (overBudgetCategories.isNotEmpty) {
      // Сортируем категории по величине перерасхода
      final sortedCategories =
          overBudgetCategories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      // Берем топ-3 категории с наибольшим перерасходом
      final topCategories = sortedCategories.take(3).toList();

      // Рассчитываем общий перерасход
      final totalOverspend = topCategories.fold<double>(0, (sum, entry) => sum + entry.value);

      // Получаем платежи из категорий с перерасходом
      final overBudgetPayments = <IFinancialData>[];
      for (final entry in topCategories) {
        overBudgetPayments.addAll(completedByCategory[entry.key] ?? []);
      }

      // Получаем оригинальные платежи с помощью сервиса
      final relatedPayments = PaymentExtractionService.extractPayments(overBudgetPayments);

      // Формируем текст с категориями
      final categoriesText = topCategories
          .map((e) => '${e.key} (перерасход ${InsightUtils.currencyFormat.format(e.value)})')
          .join(', ');

      insights.add(
        createInsight(
          title: 'Обнаружен перерасход бюджета',
          description:
              'Я выявил значительный перерасход в нескольких категориях: $categoriesText. '
              'Общая сумма перерасхода составляет ${InsightUtils.currencyFormat.format(totalOverspend)}. '
              'Более тщательное планирование и контроль расходов в этих категориях '
              'поможет тебе оптимизировать бюджет и избежать незапланированных трат.',
          type: InsightType.optimization,
          importance: totalOverspend > 5000 ? InsightImportance.high : InsightImportance.medium,
          timeframe: InsightTimeframe.combined,
          relatedPayments: relatedPayments,
          additionalData: {
            'overBudgetCategories':
                topCategories
                    .map(
                      (e) => {
                        'category': e.key,
                        'planned': plannedTotals[e.key],
                        'actual': completedTotals[e.key],
                        'overspend': e.value,
                        'percentOver':
                            ((completedTotals[e.key]! / plannedTotals[e.key]! - 1) * 100).round(),
                      },
                    )
                    .toList(),
            'totalOverspend': totalOverspend,
          },
        ),
      );
    }

    return insights;
  }

  /// Анализирует возможности для оптимизации на основе сезонных паттернов
  List<Insight> _analyzeSeasonalOptimization(List<IFinancialData> operations) {
    final insights = <Insight>[];

    // Фильтруем только расходы
    final expenses = operations.where((op) => op.type == FinancialOperationType.expense).toList();

    if (expenses.isEmpty) {
      return insights;
    }

    // Группируем расходы по месяцам и категориям
    final expensesByMonthAndCategory = <String, Map<String, List<IFinancialData>>>{};

    for (final expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month}';
      final category = expense.category.isNotEmpty ? expense.category : 'Без категории';

      expensesByMonthAndCategory[monthKey] = expensesByMonthAndCategory[monthKey] ?? {};
      expensesByMonthAndCategory[monthKey]![category] = [
        ...(expensesByMonthAndCategory[monthKey]![category] ?? []),
        expense,
      ];
    }

    // Если данных недостаточно, возвращаем пустой список
    if (expensesByMonthAndCategory.length < 3) {
      return insights;
    }

    // Рассчитываем суммы расходов по месяцам и категориям
    final totalsByMonthAndCategory = <String, Map<String, double>>{};

    for (final monthEntry in expensesByMonthAndCategory.entries) {
      final monthKey = monthEntry.key;
      final categoryMap = monthEntry.value;

      totalsByMonthAndCategory[monthKey] = {};

      for (final categoryEntry in categoryMap.entries) {
        final category = categoryEntry.key;
        final categoryExpenses = categoryEntry.value;

        totalsByMonthAndCategory[monthKey]![category] = categoryExpenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount.toDouble(),
        );
      }
    }

    // Находим категории с сезонными пиками расходов
    final seasonalCategories = <String, Map<String, double>>{};

    // Для каждой категории
    final allCategories = <String>{};
    for (final monthData in totalsByMonthAndCategory.values) {
      allCategories.addAll(monthData.keys);
    }

    for (final category in allCategories) {
      // Собираем данные по месяцам для этой категории
      final monthlyData = <String, double>{};

      for (final monthEntry in totalsByMonthAndCategory.entries) {
        final monthKey = monthEntry.key;
        final categoryTotal = monthEntry.value[category] ?? 0;

        if (categoryTotal > 0) {
          monthlyData[monthKey] = categoryTotal;
        }
      }

      // Если категория встречается минимум в 3 месяцах
      if (monthlyData.length >= 3) {
        // Рассчитываем среднее значение
        final avgMonthly = monthlyData.values.average;

        // Находим месяцы с расходами выше среднего на 30%
        final highMonths =
            monthlyData.entries.where((entry) => entry.value > avgMonthly * 1.3).toList();

        if (highMonths.isNotEmpty) {
          seasonalCategories[category] = Map.fromEntries(highMonths);
        }
      }
    }

    // Если найдены категории с сезонными пиками, создаем инсайты
    for (final entry in seasonalCategories.entries) {
      final category = entry.key;
      final highMonths = entry.value;

      // Получаем названия месяцев
      final monthNames = [
        'январь',
        'февраль',
        'март',
        'апрель',
        'май',
        'июнь',
        'июль',
        'август',
        'сентябрь',
        'октябрь',
        'ноябрь',
        'декабрь',
      ];

      // Преобразуем ключи месяцев в названия
      final highMonthNames = <String>[];
      for (final monthKey in highMonths.keys) {
        final parts = monthKey.split('-');
        if (parts.length == 2) {
          final month = int.tryParse(parts[1]);
          if (month != null && month >= 1 && month <= 12) {
            highMonthNames.add(monthNames[month - 1]);
          }
        }
      }

      // Рассчитываем среднее значение для категории по всем месяцам
      final allMonthsData = <double>[];
      for (final monthData in totalsByMonthAndCategory.values) {
        if (monthData.containsKey(category)) {
          allMonthsData.add(monthData[category]!);
        }
      }

      final avgMonthly = allMonthsData.average;

      // Рассчитываем среднее значение для высоких месяцев
      final avgHighMonths = highMonths.values.average;

      // Рассчитываем потенциальную экономию
      final potentialSavingsPerMonth = avgHighMonths - avgMonthly;
      final potentialSavingsTotal = potentialSavingsPerMonth * highMonths.length;

      // Если потенциальная экономия значительна
      if (potentialSavingsTotal >= _minSavingsAmount) {
        // Получаем платежи из категории в высокие месяцы
        final highMonthPayments = <IFinancialData>[];

        for (final monthKey in highMonths.keys) {
          if (expensesByMonthAndCategory.containsKey(monthKey) &&
              expensesByMonthAndCategory[monthKey]!.containsKey(category)) {
            highMonthPayments.addAll(expensesByMonthAndCategory[monthKey]![category]!);
          }
        }

        // Получаем оригинальные платежи с помощью сервиса
        final relatedPayments = PaymentExtractionService.extractPayments(highMonthPayments);

        insights.add(
          createInsight(
            title: 'Сезонная оптимизация расходов на $category',
            description:
                'Я заметил, что твои расходы на $category значительно выше в следующие месяцы: ${highMonthNames.join(', ')}. '
                'Если бы ты оптимизировал эти расходы до среднего уровня, то мог бы сэкономить '
                'около ${InsightUtils.currencyFormat.format(potentialSavingsTotal)} в год. '
                'Возможно, стоит заранее планировать бюджет на эти месяцы или искать альтернативные варианты.',
            type: InsightType.optimization,
            importance:
                potentialSavingsTotal > 10000 ? InsightImportance.high : InsightImportance.medium,
            timeframe: InsightTimeframe.combined,
            relatedPayments: relatedPayments,
            additionalData: {
              'category': category,
              'highMonths':
                  highMonths.entries
                      .map(
                        (e) => {
                          'monthKey': e.key,
                          'amount': e.value,
                          'percentAboveAvg': ((e.value / avgMonthly - 1) * 100).round(),
                        },
                      )
                      .toList(),
              'avgMonthly': avgMonthly,
              'avgHighMonths': avgHighMonths,
              'potentialSavingsPerMonth': potentialSavingsPerMonth,
              'potentialSavingsTotal': potentialSavingsTotal,
            },
          ),
        );
      }
    }

    return insights;
  }
}
