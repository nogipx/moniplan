// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

import '../_index.dart';
import '../categorization/_index.dart';

/// Анализатор для предложения категорий для операций
///
/// Использует автоматическую категоризацию платежей и предлагает
/// категории для операций без категорий или с общими категориями
final class CategorySuggestionAnalyzer extends RetrospectiveAnalyzer {
  /// Категоризатор платежей
  final ICategoryPredictor _categorizer;
  final List<Payment> _payments;

  /// Конструктор
  CategorySuggestionAnalyzer(super.source, ICategoryPredictor categorizer, List<Payment> payments)
    : _categorizer = categorizer,
      _payments = payments;

  @override
  Future<AnalysisResult> analyze({Map<String, dynamic>? analysisData}) async {
    final operations = availableOperations;

    // Если нет операций, возвращаем пустой результат
    if (operations.isEmpty) {
      return AnalysisResult.empty();
    }

    // Категоризируем операции и анализируем их
    return _categorizeAndAnalyze(operations, analysisData ?? {});
  }

  /// Категоризирует операции и анализирует их
  Future<AnalysisResult> _categorizeAndAnalyze(
    List<IFinancialData> operations,
    Map<String, dynamic> analysisData,
  ) async {
    final insights = <Insight>[];

    // Категоризируем операции
    final categorizedOperations = await _categorizeOperations(operations);

    // Находим операции с общими или пустыми категориями
    final operationsWithGenericCategories = _findOperationsWithGenericCategories(
      categorizedOperations,
    );

    // Если есть операции с общими категориями, создаем инсайт
    if (operationsWithGenericCategories.isNotEmpty) {
      insights.add(_createCategorySuggestionInsight(operationsWithGenericCategories));
    }

    return AnalysisResult(insights: insights, analysisData: analysisData);
  }

  /// Категоризирует операции
  Future<List<_CategorizedFinancialData>> _categorizeOperations(
    List<IFinancialData> operations,
  ) async {
    // Категоризируем операции
    final categorizedOperations = await Future.wait(
      operations.map(
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

    // Объединяем операции с категориями и категоризированные операции
    return categorizedOperations
        .map(
          (e) => _CategorizedFinancialData(
            originalData: e.key,
            category: e.key.category,
            categoryPredictions: e.value,
          ),
        )
        .toList();
  }

  /// Находит операции с общими или пустыми категориями
  List<_CategorizedFinancialData> _findOperationsWithGenericCategories(
    List<_CategorizedFinancialData> operations,
  ) {
    // Список общих категорий
    final genericCategories = [
      'покупка',
      'оплата',
      'платеж',
      'перевод',
      'расход',
      'доход',
      'зачисление',
      'списание',
      'прочее',
      'разное',
      'другое',
    ];

    // Находим операции с общими или пустыми категориями
    return operations.where((op) {
      final category = op.category.toLowerCase();
      return category.isEmpty ||
          genericCategories.any((generic) => category.contains(generic)) ||
          op.categoryPredictions.isNotEmpty && op.categoryPredictions.first.probability > 0.7;
    }).toList();
  }

  /// Создает инсайт с предложениями категорий
  Insight _createCategorySuggestionInsight(List<_CategorizedFinancialData> operations) {
    // Создаем инсайт
    return Insight(
      id: 'category_suggestion_insight',
      title: 'Предложения по категоризации',
      description:
          'Для ${operations.length} операций можно уточнить категории для более точного анализа.',
      detailedDescription:
          'Для некоторых операций можно уточнить категории для более точного анализа расходов. '
          'Я проанализировал твои платежи и предлагаю более подходящие категории для ${operations.length} операций.\n\n'
          'Правильная категоризация платежей помогает получать более точные инсайты о структуре расходов, '
          'выявлять тренды и находить возможности для оптимизации бюджета. '
          'Рекомендую регулярно проверять и уточнять категории для новых платежей.',
      timeframe: InsightTimeframe.retrospective,
      importance: InsightImportance.medium,
      type: InsightType.advice,
      additionalData: {
        'operations':
            operations.map((op) {
              return {
                'id': op.id,
                'name': op.category,
                'amount': op.amount,
                'date': op.date.toIso8601String(),
                'type': op.type.toString(),
                'suggestions':
                    op.categoryPredictions.map((prediction) {
                      return {
                        'category': prediction.category,
                        'probability': prediction.probability,
                      };
                    }).toList(),
              };
            }).toList(),
      },
    );
  }
}

/// Обертка для финансовых данных с категорией
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
  num get amount => originalData.amount;

  @override
  DateTime get date => originalData.date;

  @override
  String get id => originalData.id;

  @override
  FinancialOperationType get type => originalData.type;

  @override
  FinancialOperationStatus get status => originalData.status;

  @override
  Map<String, dynamic>? get additionalData => originalData.additionalData;
}
