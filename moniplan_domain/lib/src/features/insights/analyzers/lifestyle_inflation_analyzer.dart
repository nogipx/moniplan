// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:uuid/uuid.dart';

import '../_index.dart';

/// Анализатор инфляции образа жизни
///
/// Отслеживает рост расходов относительно роста доходов
/// Выявляет категории с наибольшим ростом
/// Предлагает стратегии контроля расходов
final class LifestyleInflationAnalyzer extends RetrospectiveAnalyzer {
  final _uuid = Uuid();

  // Пороговые значения для анализа
  static const _significantInflationPercent = 15.0; // 15% считается значительным ростом
  static const _minDataPeriodMonths = 3; // Минимальный период для анализа (в месяцах)

  LifestyleInflationAnalyzer(super.source);

  @override
  AnalysisResult analyze({Map<String, dynamic>? analysisData}) {
    final insights = <Insight>[];

    // Используем геттер для получения только завершенных операций
    final completedOperations = availableOperations;

    // Если недостаточно данных, возвращаем пустой список
    if (completedOperations.length < 10) {
      // Требуется минимальное количество операций
      return AnalysisResult.empty();
    }

    // Сортируем операции по дате
    completedOperations.sort((a, b) => a.date.compareTo(b.date));

    // Определяем временной диапазон данных
    final firstDate = completedOperations.first.date;
    final lastDate = completedOperations.last.date;

    // Проверяем, достаточно ли данных для анализа (минимум 3 месяца)
    final diffMonths = (lastDate.year - firstDate.year) * 12 + lastDate.month - firstDate.month;
    if (diffMonths < _minDataPeriodMonths) {
      return AnalysisResult.empty();
    }

    // Разделяем данные на две половины для сравнения
    final midpoint = completedOperations.length ~/ 2;
    final firstHalf = completedOperations.sublist(0, midpoint);
    final secondHalf = completedOperations.sublist(midpoint);

    // Анализируем доходы и расходы в обоих периодах
    final firstHalfAnalysis = _analyzeOperations(firstHalf);
    final secondHalfAnalysis = _analyzeOperations(secondHalf);

    // 1. Анализ общего роста расходов относительно доходов
    insights.add(_createOverallInflationInsight(firstHalfAnalysis, secondHalfAnalysis));

    // 2. Анализ роста расходов по категориям
    insights.add(_createCategoryInflationInsight(firstHalfAnalysis, secondHalfAnalysis));

    return AnalysisResult(insights: insights, analysisData: analysisData ?? {});
  }

  /// Анализирует операции и возвращает структуру с результатами
  Map<String, dynamic> _analyzeOperations(List<IFinancialData> operations) {
    // Фильтруем доходы и расходы
    final incomeOperations =
        operations.where((op) => op.type == FinancialOperationType.income).toList();

    final expenseOperations =
        operations.where((op) => op.type == FinancialOperationType.expense).toList();

    // Рассчитываем общий доход и расходы
    final totalIncome = incomeOperations.fold<double>(
      0,
      (sum, op) => sum + op.amount.abs().toDouble(),
    );

    final totalExpenses = expenseOperations.fold<double>(
      0,
      (sum, op) => sum + op.amount.abs().toDouble(),
    );

    // Группируем расходы по категориям
    final categoryExpenses = <String, double>{};

    for (final operation in expenseOperations) {
      final category = operation.category;
      categoryExpenses[category] =
          (categoryExpenses[category] ?? 0) + operation.amount.abs().toDouble();
    }

    // Возвращаем результаты анализа
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'categoryExpenses': categoryExpenses,
      'operationsCount': operations.length,
      'startDate': operations.first.date,
      'endDate': operations.last.date,
    };
  }

  /// Создает инсайт об общей инфляции образа жизни
  Insight _createOverallInflationInsight(
    Map<String, dynamic> firstHalfAnalysis,
    Map<String, dynamic> secondHalfAnalysis,
  ) {
    final firstHalfIncome = firstHalfAnalysis['totalIncome'] as double;
    final firstHalfExpenses = firstHalfAnalysis['totalExpenses'] as double;
    final secondHalfIncome = secondHalfAnalysis['totalIncome'] as double;
    final secondHalfExpenses = secondHalfAnalysis['totalExpenses'] as double;

    // Рассчитываем процентное изменение доходов и расходов
    final incomeChange = ((secondHalfIncome - firstHalfIncome) / firstHalfIncome) * 100;
    final expenseChange = ((secondHalfExpenses - firstHalfExpenses) / firstHalfExpenses) * 100;

    // Рассчитываем разницу между ростом расходов и ростом доходов
    final inflationGap = expenseChange - incomeChange;

    final hasLifestyleInflation = inflationGap > 0;
    final isSignificant = inflationGap.abs() > _significantInflationPercent;

    final title =
        hasLifestyleInflation
            ? isSignificant
                ? 'Значительная инфляция образа жизни'
                : 'Умеренная инфляция образа жизни'
            : 'Контролируемые расходы';

    final description =
        hasLifestyleInflation
            ? 'Твои расходы растут на ${inflationGap.toStringAsFixed(1)}% быстрее, чем доходы. '
                'Это может привести к финансовым трудностям в будущем. Рекомендуется пересмотреть '
                'структуру расходов и найти возможности для экономии.'
            : 'Отличная работа! Твои расходы растут медленнее, чем доходы (на ${(-inflationGap).toStringAsFixed(1)}%). '
                'Это позволяет увеличивать сбережения и создает запас прочности для твоего бюджета.';

    return Insight(
      id: _uuid.v4(),
      title: title,
      description: description,
      type: InsightType.pattern,
      importance:
          hasLifestyleInflation && isSignificant
              ? InsightImportance.high
              : hasLifestyleInflation
              ? InsightImportance.medium
              : InsightImportance.low,
      timeframe: InsightTimeframe.retrospective,
      additionalData: {
        'incomeChange': incomeChange,
        'expenseChange': expenseChange,
        'inflationGap': inflationGap,
        'firstHalfIncome': firstHalfIncome,
        'firstHalfExpenses': firstHalfExpenses,
        'secondHalfIncome': secondHalfIncome,
        'secondHalfExpenses': secondHalfExpenses,
        'hasLifestyleInflation': hasLifestyleInflation,
        'isSignificant': isSignificant,
      },
    );
  }

  /// Создает инсайт о росте расходов по категориям
  Insight _createCategoryInflationInsight(
    Map<String, dynamic> firstHalfAnalysis,
    Map<String, dynamic> secondHalfAnalysis,
  ) {
    final firstHalfCategoryExpenses = firstHalfAnalysis['categoryExpenses'] as Map<String, double>;
    final secondHalfCategoryExpenses =
        secondHalfAnalysis['categoryExpenses'] as Map<String, double>;

    // Находим категории, присутствующие в обоих периодах
    final commonCategories =
        firstHalfCategoryExpenses.keys
            .where((category) => secondHalfCategoryExpenses.containsKey(category))
            .toList();

    // Рассчитываем изменение расходов по категориям
    final categoryChanges = <String, double>{};
    final categoryChangePercents = <String, double>{};

    for (final category in commonCategories) {
      final firstHalfAmount = firstHalfCategoryExpenses[category]!;
      final secondHalfAmount = secondHalfCategoryExpenses[category]!;

      final change = secondHalfAmount - firstHalfAmount;
      final changePercent = (change / firstHalfAmount) * 100;

      categoryChanges[category] = change;
      categoryChangePercents[category] = changePercent;
    }

    // Сортируем категории по проценту изменения (от большего к меньшему)
    commonCategories.sort(
      (a, b) => categoryChangePercents[b]!.compareTo(categoryChangePercents[a]!),
    );

    // Выбираем топ-3 категории с наибольшим ростом
    final topGrowthCategories =
        commonCategories
            .where((category) => categoryChangePercents[category]! > 0)
            .take(3)
            .toList();

    if (topGrowthCategories.isEmpty) {
      // Если нет категорий с ростом, создаем позитивный инсайт
      return Insight(
        id: _uuid.v4(),
        title: 'Стабильные расходы по категориям',
        description:
            'Отличная работа! Ни в одной категории расходов не наблюдается значительного роста. '
            'Это говорит о хорошем контроле над бюджетом и финансовой дисциплине.',
        type: InsightType.pattern,
        importance: InsightImportance.low,
        timeframe: InsightTimeframe.retrospective,
        additionalData: {
          'categoryChanges': categoryChanges,
          'categoryChangePercents': categoryChangePercents,
        },
      );
    }

    // Формируем описание топ-категорий с ростом
    final categoriesDescription = topGrowthCategories
        .map(
          (category) =>
              '$category (рост на ${categoryChangePercents[category]!.toStringAsFixed(1)}%)',
        )
        .join(', ');

    return Insight(
      id: _uuid.v4(),
      title: 'Категории с наибольшим ростом расходов',
      description:
          'Я заметил значительный рост расходов в следующих категориях: $categoriesDescription. '
          'Обрати внимание на эти категории, возможно, здесь есть потенциал для оптимизации расходов '
          'и предотвращения инфляции образа жизни.',
      type: InsightType.pattern,
      importance: InsightImportance.medium,
      timeframe: InsightTimeframe.retrospective,
      additionalData: {
        'topGrowthCategories': topGrowthCategories,
        'categoryChanges': categoryChanges,
        'categoryChangePercents': categoryChangePercents,
      },
    );
  }
}
