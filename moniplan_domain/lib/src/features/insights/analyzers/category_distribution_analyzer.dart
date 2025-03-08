// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:collection/collection.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import '../_index.dart';
import '../categorization/_index.dart';

/// Анализатор распределения расходов по категориям
///
/// Использует автоматическую категоризацию платежей и анализирует
/// распределение расходов по категориям
final class CategoryDistributionAnalyzer extends RetrospectiveAnalyzer {
  /// Категоризатор платежей
  final ICategoryPredictor _categorizer;
  final List<Payment> _payments;

  /// Конструктор
  CategoryDistributionAnalyzer(super.source, ICategoryPredictor categorizer, List<Payment> payments)
    : _categorizer = categorizer,
      _payments = payments;

  @override
  Future<AnalysisResult> analyze({Map<String, dynamic>? analysisData}) async {
    final operations = availableOperations;

    // Фильтруем только расходы
    final expenses = operations.where((op) => op.type == FinancialOperationType.expense).toList();

    if (expenses.isEmpty) {
      return AnalysisResult.empty();
    }

    // Категоризируем платежи без категорий и анализируем их
    return _categorizeAndAnalyze(expenses, analysisData);
  }

  /// Категоризирует платежи и анализирует их
  Future<AnalysisResult> _categorizeAndAnalyze(
    List<IFinancialData> expenses,
    Map<String, dynamic>? analysisData,
  ) async {
    final insights = <Insight>[];

    // Категоризируем платежи без категорий
    final categorizedExpenses = await _categorizeExpenses(expenses);

    // Анализируем распределение расходов по категориям
    insights.addAll(_analyzeDistribution(categorizedExpenses));

    // Анализируем динамику расходов по категориям
    insights.addAll(_analyzeDynamics(categorizedExpenses));

    return AnalysisResult(
      insights: InsightUtils.setTimeframeForAll(insights, InsightTimeframe.retrospective),
      analysisData: {
        'categorizedExpenses':
            categorizedExpenses
                .map(
                  (e) => {
                    'id': e.id,
                    'amount': e.amount,
                    'category': e.category,
                    'date': e.date.toIso8601String(),
                  },
                )
                .toList(),
        ...?analysisData,
      },
    );
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
                type:
                    e.type == FinancialOperationType.expense
                        ? PaymentType.expense
                        : PaymentType.income,
                currency: CurrencyData.create('', 2),
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
          (e) => _CategorizedFinancialData(originalData: e.key, category: e.value.first.category),
        )
        .toList();
  }

  /// Анализирует распределение расходов по категориям
  List<Insight> _analyzeDistribution(List<IFinancialData> expenses) {
    final insights = <Insight>[];

    // Группируем расходы по категориям
    final expensesByCategory = <String, List<IFinancialData>>{};
    for (final expense in expenses) {
      final category = expense.category;
      expensesByCategory[category] = [...(expensesByCategory[category] ?? []), expense];
    }

    // Рассчитываем суммы расходов по категориям
    final categoryTotals = <String, double>{};
    for (final entry in expensesByCategory.entries) {
      categoryTotals[entry.key] = entry.value.fold<double>(
        0,
        (sum, expense) => sum + expense.amount.toDouble(),
      );
    }

    // Рассчитываем общую сумму расходов
    final totalExpenses = categoryTotals.values.sum;

    // Сортируем категории по убыванию суммы расходов
    final sortedCategories =
        categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Находим топ-3 категории расходов
    final topCategories = sortedCategories.take(3).toList();

    // Рассчитываем процент расходов в топ-3 категориях
    final topCategoriesTotal = topCategories.fold<double>(0, (sum, entry) => sum + entry.value);
    final topCategoriesPercent = (topCategoriesTotal / totalExpenses * 100).round();

    // Создаем инсайт о распределении расходов по категориям
    insights.add(
      createInsight(
        title: 'Распределение расходов по категориям',
        description:
            'Основные категории твоих расходов: ${topCategories.map((e) => e.key).join(', ')}. '
            'На них приходится $topCategoriesPercent% всех расходов. '
            'Самая крупная категория - "${topCategories.first.key}" (${(topCategories.first.value / totalExpenses * 100).round()}% расходов).',
        type: InsightType.expenseStructure,
        importance: InsightImportance.medium,
        additionalData: {
          'categoryTotals': categoryTotals,
          'totalExpenses': totalExpenses,
          'topCategories':
              topCategories
                  .map(
                    (e) => {
                      'category': e.key,
                      'total': e.value,
                      'percent': (e.value / totalExpenses * 100).round(),
                    },
                  )
                  .toList(),
        },
      ),
    );

    return insights;
  }

  /// Анализирует динамику расходов по категориям
  List<Insight> _analyzeDynamics(List<IFinancialData> expenses) {
    final insights = <Insight>[];

    // Определяем временные периоды для анализа
    final dates = expenses.map((e) => e.date).toList();
    if (dates.isEmpty) {
      return insights;
    }

    // Сортируем даты
    dates.sort();

    // Определяем начало и конец периода
    final startDate = dates.first;
    final endDate = dates.last;

    // Если период слишком короткий, не анализируем динамику
    final periodDays = endDate.difference(startDate).inDays;
    if (periodDays < 30) {
      return insights;
    }

    // Разбиваем период на две части
    final midDate = startDate.add(Duration(days: periodDays ~/ 2));

    // Разделяем расходы на две части
    final firstPeriodExpenses = expenses.where((e) => e.date.isBefore(midDate)).toList();
    final secondPeriodExpenses =
        expenses.where((e) => e.date.isAfter(midDate) || e.date.isAtSameMomentAs(midDate)).toList();

    // Если в одном из периодов нет расходов, не анализируем динамику
    if (firstPeriodExpenses.isEmpty || secondPeriodExpenses.isEmpty) {
      return insights;
    }

    // Рассчитываем суммы расходов по категориям для каждого периода
    final firstPeriodTotals = _calculateCategoryTotals(firstPeriodExpenses);
    final secondPeriodTotals = _calculateCategoryTotals(secondPeriodExpenses);

    // Находим категории с наибольшим изменением
    final categoryChanges = <String, double>{};
    for (final category in {...firstPeriodTotals.keys, ...secondPeriodTotals.keys}) {
      final firstTotal = firstPeriodTotals[category] ?? 0;
      final secondTotal = secondPeriodTotals[category] ?? 0;

      // Рассчитываем процент изменения
      if (firstTotal > 0) {
        final changePercent = (secondTotal - firstTotal) / firstTotal * 100;
        categoryChanges[category] = changePercent;
      }
    }

    // Сортируем категории по абсолютному значению изменения
    final sortedChanges =
        categoryChanges.entries.toList()..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    // Находим категории с наибольшим изменением (более 20%)
    final significantChanges =
        sortedChanges
            .where((entry) => entry.value.abs() > 20 && (firstPeriodTotals[entry.key] ?? 0) > 1000)
            .take(3)
            .toList();

    if (significantChanges.isNotEmpty) {
      // Создаем инсайт о динамике расходов по категориям
      final changesDescription = significantChanges
          .map((entry) => '"${entry.key}": ${entry.value > 0 ? '+' : ''}${entry.value.round()}%')
          .join(', ');

      insights.add(
        createInsight(
          title: 'Изменение расходов по категориям',
          description:
              'Я заметил значительные изменения в твоих расходах по некоторым категориям: $changesDescription. '
              'Это может быть связано с изменением твоих привычек или сезонными факторами.',
          type: InsightType.comparison,
          importance:
              significantChanges.any((entry) => entry.value.abs() > 50)
                  ? InsightImportance.high
                  : InsightImportance.medium,
          additionalData: {
            'firstPeriodStart': startDate.toIso8601String(),
            'firstPeriodEnd': midDate.toIso8601String(),
            'secondPeriodStart': midDate.toIso8601String(),
            'secondPeriodEnd': endDate.toIso8601String(),
            'firstPeriodTotals': firstPeriodTotals,
            'secondPeriodTotals': secondPeriodTotals,
            'categoryChanges': categoryChanges,
            'significantChanges':
                significantChanges
                    .map(
                      (e) => {
                        'category': e.key,
                        'changePercent': e.value,
                        'firstTotal': firstPeriodTotals[e.key],
                        'secondTotal': secondPeriodTotals[e.key],
                      },
                    )
                    .toList(),
          },
        ),
      );
    }

    return insights;
  }

  /// Рассчитывает суммы расходов по категориям
  Map<String, double> _calculateCategoryTotals(List<IFinancialData> expenses) {
    final result = <String, double>{};
    for (final expense in expenses) {
      final category = expense.category;
      result[category] = (result[category] ?? 0) + expense.amount.toDouble();
    }
    return result;
  }
}

/// Обертка для финансовых данных с категорией
class _CategorizedFinancialData implements IFinancialData {
  final IFinancialData originalData;
  @override
  final String category;

  _CategorizedFinancialData({required this.originalData, required this.category});

  @override
  num get amount => originalData.amount;

  @override
  DateTime get date => originalData.date;

  @override
  String get id => originalData.id;

  @override
  FinancialOperationStatus get status => originalData.status;

  @override
  FinancialOperationType get type => originalData.type;

  @override
  Map<String, dynamic>? get additionalData => originalData.additionalData;
}
