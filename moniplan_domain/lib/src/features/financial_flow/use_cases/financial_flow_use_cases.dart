// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import '../models/financial_flow_profile.dart';
import '../models/financial_flow_calculation.dart';
import '../models/financial_instrument.dart';
import '../repositories/financial_flow_repository.dart';
import '../services/financial_flow_calculation_service.dart';

/// Use case для управления профилями финансового потока
class ManageFinancialFlowProfilesUseCase {
  final FinancialFlowRepository _repository;

  ManageFinancialFlowProfilesUseCase(this._repository);

  /// Создает новый профиль
  Future<FinancialFlowProfile> createProfile({
    required String name,
    required String description,
    required dynamic defaultCurrency,
    CalculationPeriod? calculationPeriod,
    CalculationSettings? calculationSettings,
    Set<String> tags = const {},
  }) async {
    final profile = FinancialFlowProfile(
      id: _generateId(),
      name: name,
      description: description,
      defaultCurrency: defaultCurrency,
      calculationPeriod: calculationPeriod ?? CalculationPeriod.currentMonth(),
      calculationSettings: calculationSettings ?? const CalculationSettings(),
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createProfile(profile);
  }

  /// Обновляет существующий профиль
  Future<FinancialFlowProfile> updateProfile(FinancialFlowProfile profile) async {
    return await _repository.updateProfile(profile);
  }

  /// Получает все профили
  Future<List<FinancialFlowProfile>> getAllProfiles() async {
    return await _repository.getAllProfiles();
  }

  /// Получает активные профили
  Future<List<FinancialFlowProfile>> getActiveProfiles() async {
    return await _repository.getActiveProfiles();
  }

  /// Получает профиль по ID
  Future<FinancialFlowProfile?> getProfileById(String id) async {
    return await _repository.getProfileById(id);
  }

  /// Удаляет профиль
  Future<void> deleteProfile(String id) async {
    await _repository.deleteProfile(id);
  }

  /// Добавляет инструмент в профиль
  Future<FinancialFlowProfile> addInstrumentToProfile(
    String profileId,
    FinancialInstrument instrument,
  ) async {
    return await _repository.addInstrumentToProfile(profileId, instrument);
  }

  /// Обновляет инструмент в профиле
  Future<FinancialFlowProfile> updateInstrumentInProfile(
    String profileId,
    FinancialInstrument instrument,
  ) async {
    return await _repository.updateInstrumentInProfile(profileId, instrument);
  }

  /// Удаляет инструмент из профиля
  Future<FinancialFlowProfile> removeInstrumentFromProfile(
    String profileId,
    String instrumentId,
  ) async {
    return await _repository.removeInstrumentFromProfile(profileId, instrumentId);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Use case для расчета финансового потока
class CalculateFinancialFlowUseCase {
  final FinancialFlowRepository _repository;
  final FinancialFlowCalculationService _calculationService;

  CalculateFinancialFlowUseCase(this._repository, this._calculationService);

  /// Выполняет расчет финансового потока для профиля
  Future<FinancialFlowCalculation> calculateFlow(String profileId) async {
    final profile = await _repository.getProfileById(profileId);
    if (profile == null) {
      throw Exception('Profile not found: $profileId');
    }

    // Выполняем расчет
    final calculation = await _calculationService.calculateFinancialFlow(profile);
    
    // Сохраняем результат
    await _repository.saveCalculation(calculation);
    
    return calculation;
  }

  /// Быстрый расчет для одного периода
  Future<PeriodCalculationResult> calculatePeriod(
    String profileId,
    CalculationPeriod period,
  ) async {
    final profile = await _repository.getProfileById(profileId);
    if (profile == null) {
      throw Exception('Profile not found: $profileId');
    }

    return await _calculationService.calculatePeriod(profile, period);
  }

  /// Получает последний расчет для профиля
  Future<FinancialFlowCalculation?> getLatestCalculation(String profileId) async {
    return await _repository.getLatestCalculationForProfile(profileId);
  }

  /// Получает все расчеты для профиля
  Future<List<FinancialFlowCalculation>> getCalculationsHistory(String profileId) async {
    return await _repository.getCalculationsForProfile(profileId);
  }

  /// Сравнивает два расчета
  Future<FlowComparisonResult> compareCalculations(
    String calculationId1,
    String calculationId2,
  ) async {
    // Здесь можно реализовать логику сравнения расчетов
    // Пока возвращаем заглушку
    throw UnimplementedError('Comparison not implemented yet');
  }
}

/// Use case для анализа финансового потока
class AnalyzeFinancialFlowUseCase {
  final FinancialFlowRepository _repository;

  AnalyzeFinancialFlowUseCase(this._repository);

  /// Анализирует тренды доходов и расходов
  Future<FlowTrendsAnalysis> analyzeTrends(String profileId, int monthsBack) async {
    final calculations = await _repository.getCalculationsForProfile(profileId);
    
    // Фильтруем расчеты за последние monthsBack месяцев
    final cutoffDate = DateTime.now().subtract(Duration(days: monthsBack * 30));
    final recentCalculations = calculations
        .where((calc) => calc.calculatedAt.isAfter(cutoffDate))
        .toList();

    if (recentCalculations.isEmpty) {
      return FlowTrendsAnalysis.empty();
    }

    // Анализируем тренды
    final incomes = recentCalculations
        .map((calc) => calc.summary.totalIncome)
        .toList();
    
    final expenses = recentCalculations
        .map((calc) => calc.summary.totalExpenses)
        .toList();

    final netFlows = recentCalculations
        .map((calc) => calc.summary.totalNetFlow)
        .toList();

    return FlowTrendsAnalysis(
      incomeTrend: _calculateTrend(incomes),
      expenseTrend: _calculateTrend(expenses),
      netFlowTrend: _calculateTrend(netFlows),
      averageIncome: _calculateAverage(incomes),
      averageExpenses: _calculateAverage(expenses),
      averageNetFlow: _calculateAverage(netFlows),
      periodsAnalyzed: recentCalculations.length,
    );
  }

  /// Получает топ категорий по расходам
  Future<List<CategoryAnalysis>> getTopExpenseCategories(
    String profileId,
    int topCount,
  ) async {
    final latestCalculation = await _repository.getLatestCalculationForProfile(profileId);
    if (latestCalculation == null) {
      return [];
    }

    final categoryTotals = <String, num>{};

    // Собираем данные по категориям из всех периодов
    for (final periodResult in latestCalculation.periodResults) {
      for (final entry in periodResult.categoryResults.entries) {
        categoryTotals[entry.key] = (categoryTotals[entry.key] ?? 0) + entry.value.abs();
      }
    }

    // Сортируем и берем топ
    final sortedCategories = categoryTotals.entries
        .map((entry) => CategoryAnalysis(
              category: entry.key,
              totalAmount: entry.value,
              percentage: entry.value / categoryTotals.values.reduce((a, b) => a + b) * 100,
            ))
        .toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return sortedCategories.take(topCount).toList();
  }

  /// Получает прогноз на следующий период
  Future<FlowForecast> getForecast(String profileId, int monthsAhead) async {
    final latestCalculation = await _repository.getLatestCalculationForProfile(profileId);
    if (latestCalculation == null) {
      throw Exception('No calculations found for profile');
    }

    // Простой прогноз на основе последнего расчета
    final summary = latestCalculation.summary;
    
    return FlowForecast(
      forecastPeriodMonths: monthsAhead,
      projectedIncome: summary.averageMonthlyIncome * monthsAhead,
      projectedExpenses: summary.averageMonthlyExpenses * monthsAhead,
      projectedNetFlow: summary.averageMonthlyNetFlow * monthsAhead,
      confidence: 0.75, // Упрощенная оценка уверенности
      assumptions: [
        'Прогноз основан на последнем расчете',
        'Предполагается сохранение текущих трендов',
        'Не учтены сезонные колебания',
      ],
    );
  }

  TrendDirection _calculateTrend(List<num> values) {
    if (values.length < 2) return TrendDirection.stable;

    final first = values.first;
    final last = values.last;
    final middle = values.length > 2 ? values[values.length ~/ 2] : (first + last) / 2;

    if (last > first && last > middle) return TrendDirection.growing;
    if (last < first && last < middle) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  num _calculateAverage(List<num> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

/// Результат сравнения двух расчетов
class FlowComparisonResult {
  final String calculationId1;
  final String calculationId2;
  final num incomeDifference;
  final num expenseDifference;
  final num netFlowDifference;
  final Map<String, num> categoryDifferences;

  FlowComparisonResult({
    required this.calculationId1,
    required this.calculationId2,
    required this.incomeDifference,
    required this.expenseDifference,
    required this.netFlowDifference,
    required this.categoryDifferences,
  });
}

/// Анализ трендов финансового потока
class FlowTrendsAnalysis {
  final TrendDirection incomeTrend;
  final TrendDirection expenseTrend;
  final TrendDirection netFlowTrend;
  final num averageIncome;
  final num averageExpenses;
  final num averageNetFlow;
  final int periodsAnalyzed;

  FlowTrendsAnalysis({
    required this.incomeTrend,
    required this.expenseTrend,
    required this.netFlowTrend,
    required this.averageIncome,
    required this.averageExpenses,
    required this.averageNetFlow,
    required this.periodsAnalyzed,
  });

  factory FlowTrendsAnalysis.empty() {
    return FlowTrendsAnalysis(
      incomeTrend: TrendDirection.stable,
      expenseTrend: TrendDirection.stable,
      netFlowTrend: TrendDirection.stable,
      averageIncome: 0,
      averageExpenses: 0,
      averageNetFlow: 0,
      periodsAnalyzed: 0,
    );
  }
}

/// Направление тренда
enum TrendDirection {
  growing,
  declining,
  stable,
}

/// Анализ категории расходов
class CategoryAnalysis {
  final String category;
  final num totalAmount;
  final double percentage;

  CategoryAnalysis({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });
}

/// Прогноз финансового потока
class FlowForecast {
  final int forecastPeriodMonths;
  final num projectedIncome;
  final num projectedExpenses;
  final num projectedNetFlow;
  final double confidence;
  final List<String> assumptions;

  FlowForecast({
    required this.forecastPeriodMonths,
    required this.projectedIncome,
    required this.projectedExpenses,
    required this.projectedNetFlow,
    required this.confidence,
    required this.assumptions,
  });
}
