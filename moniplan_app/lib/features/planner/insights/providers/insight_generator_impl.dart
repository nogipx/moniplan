// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:logging/logging.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/core/services/tflite_category_predictor.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import 'moniplan_adapters.dart';

/// Реализация генератора инсайтов
class InsightGeneratorImpl implements IInsightGenerator {
  final _logger = Logger('InsightGeneratorImpl');
  final IAnalyzerFactory _analyzerFactory;
  final ICategoryPredictor _categoryPredictor;

  InsightGeneratorImpl({IAnalyzerFactory? analyzerFactory, ICategoryPredictor? categoryPredictor})
    : _analyzerFactory = analyzerFactory ?? AnalyzerFactoryImpl(),
      _categoryPredictor = categoryPredictor ?? AppDi.instance.getPaymentCategorizer();

  @override
  Future<List<Insight>> generateInsights(Planner planner) async {
    // Создаем адаптер для планера
    final periodAdapter = MoniplanPlannerFinancialSource(planner);

    // Инициализируем предиктор категорий
    if (!_categoryPredictor.isInitialized) {
      await _categoryPredictor.initialize();
    }

    // Создаем кастомные анализаторы с ML категоризатором
    final customAnalyzers = <String, IFinancialAnalyzer>{
      'ml_category_distribution_analyzer': CategoryDistributionAnalyzer(
        periodAdapter,
        _categoryPredictor,
        planner.payments,
      ),
    };

    // Регистрируем кастомные анализаторы и инициализируем
    _analyzerFactory.registerCustomAnalyzers(customAnalyzers);
    _analyzerFactory.initAnalyzersData(periodAdapter, _categoryPredictor);

    // Проверяем, достаточно ли данных для анализа
    final allCompletedOperations = periodAdapter.completedOperations;
    final allPlannedOperations = periodAdapter.plannedOperations;
    final hasCompletedData = allCompletedOperations.length >= 2;
    final hasPlannedData = allPlannedOperations.isNotEmpty;

    if (!hasCompletedData && !hasPlannedData) {
      _logger.info(
        'Недостаточно данных для анализа (${allCompletedOperations.length} завершенных, ${allPlannedOperations.length} запланированных)',
      );
      return [];
    }

    // Создаем анализаторы и генерируем инсайты
    final analyzers = _analyzerFactory.createAllAnalyzers();
    final results = <AnalysisResult>[];

    for (final analyzer in analyzers) {
      try {
        final result = await analyzer.analyze();
        results.add(result);
      } catch (e) {
        print('Ошибка при генерации инсайтов с помощью ${analyzer.runtimeType}: $e');
      }
    }

    return results.expand((result) => result.insights).toList();
  }

  @override
  Future<List<Insight>> generateRetrospectiveInsights(Planner planner) async {
    final insights = await generateInsights(planner);
    return insights
        .where((insight) => insight.timeframe == InsightTimeframe.retrospective)
        .toList();
  }

  @override
  Future<List<Insight>> generatePredictiveInsights(Planner planner) async {
    final insights = await generateInsights(planner);
    return insights.where((insight) => insight.timeframe == InsightTimeframe.predictive).toList();
  }

  @override
  Future<List<Insight>> generateCombinedInsights(Planner planner) async {
    final insights = await generateInsights(planner);
    return insights.where((insight) => insight.timeframe == InsightTimeframe.combined).toList();
  }

  @override
  Future<List<Insight>> generateDailyInsights(Planner planner) async {
    final insights = await generateInsights(planner);
    return insights
        .where(
          (insight) =>
              insight.title.toLowerCase().contains('день') ||
              insight.title.toLowerCase().contains('дневн') ||
              insight.description.toLowerCase().contains('день') ||
              insight.description.toLowerCase().contains('дневн'),
        )
        .toList();
  }
}
