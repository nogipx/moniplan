// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:logging/logging.dart';
import 'package:moniplan_app/core/utils/shared_preferences_settings_storage.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import 'moniplan_adapters.dart';

/// Адаптер для преобразования SharedPreferencesSettingsStorage в ISettingsStorage
class SettingsStorageAdapter implements ISettingsStorage {
  final SettingsStorage _storage;

  SettingsStorageAdapter(this._storage);

  @override
  Future<String?> getString(String key) => _storage.getString(key);

  @override
  Future<void> saveString(String key, String value) => _storage.saveString(key, value);
}

/// Реализация генератора инсайтов
class InsightGeneratorImpl implements IInsightGenerator {
  final _logger = Logger('InsightGeneratorImpl');

  /// Фабрика анализаторов
  final IAnalyzerFactory _analyzerFactory;

  /// Сервис настроек анализаторов
  final IAnalyzerSettingsService _settingsService;

  /// Конструктор
  InsightGeneratorImpl({
    IAnalyzerFactory? analyzerFactory,
    IAnalyzerSettingsService? settingsService,
  }) : _analyzerFactory = analyzerFactory ?? AnalyzerFactoryImpl(),
       _settingsService =
           settingsService ??
           AnalyzerSettingsService(
             analyzerFactory: analyzerFactory ?? AnalyzerFactoryImpl(),
             settingsStorage: SettingsStorageAdapter(SharedPreferencesSettingsStorage()),
           );

  @override
  Future<List<Insight>> generateInsights(Planner planner) async {
    // Загружаем настройки анализаторов
    await _settingsService.loadSettings();

    // Получаем идентификаторы включенных анализаторов
    final enabledAnalyzerIds = _settingsService.getEnabledAnalyzerIds();

    // Создаем адаптер для планера
    final periodAdapter = MoniplanPlannerFinancialSource(planner);

    // Получаем завершенные и запланированные операции
    final allCompletedOperations = periodAdapter.completedOperations;
    final allPlannedOperations = periodAdapter.plannedOperations;

    // Проверяем, достаточно ли данных для анализа
    final hasCompletedData = allCompletedOperations.length >= 2;
    final hasPlannedData = allPlannedOperations.isNotEmpty;

    if (!hasCompletedData && !hasPlannedData) {
      _logger.info(
        'Недостаточно данных для анализа (${allCompletedOperations.length} завершенных, ${allPlannedOperations.length} запланированных)',
      );
      return [];
    }

    // Создаем анализаторы по идентификаторам
    final analyzers = _analyzerFactory.createAnalyzers(enabledAnalyzerIds);

    // Список для хранения всех инсайтов
    final results = <AnalysisResult>[];

    // Для каждого анализатора генерируем инсайты
    for (final analyzer in analyzers) {
      try {
        final result = analyzer.analyze();
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
    // Фильтруем инсайты, связанные с ежедневным анализом
    // Так как нет специального типа для ежедневных инсайтов,
    // используем фильтрацию по описанию или другим признакам
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
