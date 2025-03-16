// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// Анализатор инфляции образа жизни
///
/// Отслеживает рост расходов относительно роста доходов
/// Выявляет категории с наибольшим ростом
/// Предлагает стратегии контроля расходов
final class LifestyleInflationAnalyzer extends RetrospectiveAnalyzer {
  // Пороговые значения для анализа
  static const _significantInflationPercent = 15.0; // 15% считается значительным ростом
  static const _minDataPeriodMonths = 3; // Минимальный период для анализа (в месяцах)

  /// Категоризатор платежей
  final ICategoryPredictor _categorizer;

  LifestyleInflationAnalyzer(super.source, ICategoryPredictor categorizer)
    : _categorizer = categorizer;

  @override
  Future<AnalysisResult> analyze({Map<String, dynamic>? analysisData}) async {
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

    // Категоризируем операции
    final categorizedOperations = await _categorizeExpenses(completedOperations);

    // Разделяем данные на две половины для сравнения
    final midpoint = categorizedOperations.length ~/ 2;
    final firstHalf = categorizedOperations.sublist(0, midpoint);
    final secondHalf = categorizedOperations.sublist(midpoint);

    // Анализируем доходы и расходы в обоих периодах
    final firstHalfAnalysis = _analyzeOperations(firstHalf);
    final secondHalfAnalysis = _analyzeOperations(secondHalf);

    // 1. Анализ общего роста расходов относительно доходов
    insights.add(_createOverallInflationInsight(firstHalfAnalysis, secondHalfAnalysis));

    // 2. Анализ роста расходов по категориям
    insights.add(_createCategoryInflationInsight(firstHalfAnalysis, secondHalfAnalysis));

    return AnalysisResult(insights: insights, analysisData: analysisData ?? {});
  }

  /// Категоризирует расходы без категорий
  Future<List<IFinancialData>> _categorizeExpenses(List<IFinancialData> expenses) async {
    // Категоризируем расходы без категорий
    final categorizedExpenses = await Future.wait(
      expenses.map(
        (e) async => MapEntry(
          e,
          await _categorizer.predictCategory(
            Payment(
              paymentId: e.id,
              details: PaymentDetails(
                name: e.category,
                money: e.amount.toDouble(),
                type:
                    e.type == FinancialOperationType.expense
                        ? PaymentType.expense
                        : PaymentType.income,
                currency: CurrencyData.create('RUB', 2),
              ),
              date: e.date,
            ),
          ),
        ),
      ),
    );

    // Объединяем расходы с категориями и категоризированные расходы
    return categorizedExpenses
        .map(
          (e) => _CategorizedFinancialData(
            originalData: e.key,
            // Используем предсказанную категорию, если она есть, иначе используем оригинальную категорию
            category: e.value.isNotEmpty ? e.value.first.category : e.key.category,
            categoryPredictions: e.value,
          ),
        )
        .toList();
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
            ? 'Расходы растут на ${inflationGap.toStringAsFixed(1)}% быстрее доходов.'
            : 'Расходы растут медленнее доходов на ${(-inflationGap).toStringAsFixed(1)}%.';

    final detailedDescription =
        hasLifestyleInflation
            ? 'Твои расходы растут на ${inflationGap.toStringAsFixed(1)}% быстрее, чем доходы. '
                'Это может привести к финансовым трудностям в будущем. Рекомендуется пересмотреть '
                'структуру расходов и найти возможности для экономии.\n\n'
                'Инфляция образа жизни — это явление, при котором расходы растут быстрее, чем доходы, '
                'из-за повышения уровня жизни или появления новых потребностей. '
                'Это может привести к финансовому стрессу и снижению способности к накоплению сбережений.'
            : 'Отличная работа! Твои расходы растут медленнее, чем доходы (на ${(-inflationGap).toStringAsFixed(1)}%). '
                'Это позволяет увеличивать сбережения и создает запас прочности для твоего бюджета.\n\n'
                'Контроль над ростом расходов — важный аспект финансового благополучия. '
                'Когда расходы растут медленнее доходов, появляется возможность увеличивать сбережения, '
                'инвестировать и создавать финансовую подушку безопасности.';

    return createInsight(
      title: title,
      description: description,
      detailedDescription: detailedDescription,
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
      return createInsight(
        title: 'Стабильные расходы по категориям',
        description: 'Ни в одной категории не наблюдается значительного роста расходов.',
        detailedDescription:
            'Отличная работа! Ни в одной категории расходов не наблюдается значительного роста. '
            'Это говорит о хорошем контроле над бюджетом и финансовой дисциплине.\n\n'
            'Стабильность расходов по категориям — важный показатель финансового здоровья. '
            'Это означает, что ты хорошо контролируешь свои траты и не допускаешь необоснованного роста расходов. '
            'Продолжай в том же духе!',
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

    return createInsight(
      title: 'Категории с наибольшим ростом расходов',
      description: 'Значительный рост расходов в категориях: $categoriesDescription.',
      detailedDescription:
          'Я заметил значительный рост расходов в следующих категориях: $categoriesDescription. '
          'Обрати внимание на эти категории, возможно, здесь есть потенциал для оптимизации расходов '
          'и предотвращения инфляции образа жизни.\n\n'
          'Рост расходов в отдельных категориях может быть признаком изменения привычек или появления новых потребностей. '
          'Анализ этих изменений поможет понять, являются ли они необходимыми или есть возможность оптимизировать расходы. '
          'Регулярный мониторинг категорий с высоким ростом поможет предотвратить неконтролируемое увеличение расходов.',
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

/// Класс для хранения категоризированных финансовых данных
class _CategorizedFinancialData implements IFinancialData {
  final IFinancialData originalData;
  @override
  final String category;
  final List<CategoryPrediction> categoryPredictions;

  _CategorizedFinancialData({
    required this.originalData,
    required this.category,
    required this.categoryPredictions,
  });

  @override
  String get id => originalData.id;

  @override
  DateTime get date => originalData.date;

  @override
  num get amount => originalData.amount;

  @override
  FinancialOperationType get type => originalData.type;

  @override
  FinancialOperationStatus get status => originalData.status;

  @override
  Map<String, dynamic>? get additionalData => {
    ...?originalData.additionalData,
    'categoryPredictions':
        categoryPredictions
            .map((p) => {'category': p.category, 'probability': p.probability})
            .toList(),
    'originalCategory': originalData.category,
  };
}
