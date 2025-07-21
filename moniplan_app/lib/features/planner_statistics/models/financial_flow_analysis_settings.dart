// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

part 'financial_flow_analysis_settings.freezed.dart';
part 'financial_flow_analysis_settings.g.dart';

/// Настройки для анализа финансового потока
@freezed
class FinancialFlowAnalysisSettings with _$FinancialFlowAnalysisSettings {
  const factory FinancialFlowAnalysisSettings({
    /// Начальная дата анализа
    required DateTime startDate,
    
    /// Конечная дата анализа
    required DateTime endDate,
    
    /// Шаг расчета (месячный, квартальный и т.д.)
    @Default(CalculationStep.monthly) CalculationStep calculationStep,
    
    /// Валюта по умолчанию для анализа
    required CurrencyData defaultCurrency,
    
    /// Показывать ли только активные инструменты
    @Default(true) bool showActiveOnly,
    
    /// Группировать ли инструменты по тегам
    @Default(false) bool groupByTags,
    
    /// Включить ли прогнозирование
    @Default(false) bool enableForecasting,
    
    /// Количество периодов для прогноза
    @Default(3) int forecastPeriods,
    
    /// Настройки расчета
    @Default(CalculationSettings()) CalculationSettings calculationSettings,
    
    /// Фильтры по тегам
    @Default({}) Set<String> tagFilters,
    
    /// Тип анализируемых инструментов
    @Default({}) Set<FinancialInstrumentType> instrumentTypeFilters,
  }) = _FinancialFlowAnalysisSettings;

  factory FinancialFlowAnalysisSettings.fromJson(Map<String, dynamic> json) =>
      _$FinancialFlowAnalysisSettingsFromJson(json);

  const FinancialFlowAnalysisSettings._();

  /// Создает настройки по умолчанию для указанного планировщика
  factory FinancialFlowAnalysisSettings.fromPlanner(Planner planner) {
    return FinancialFlowAnalysisSettings(
      startDate: planner.dateStart,
      endDate: planner.dateEnd,
      defaultCurrency: planner.payments.isNotEmpty
          ? planner.payments.first.details.currency
          : CurrencyDataCommon.rub,
      calculationStep: _determineOptimalStep(planner.dateStart, planner.dateEnd),
    );
  }

  /// Определяет оптимальный шаг расчета на основе периода
  static CalculationStep _determineOptimalStep(DateTime startDate, DateTime endDate) {
    final duration = endDate.difference(startDate).inDays;
    
    if (duration <= 31) {
      return CalculationStep.daily;
    } else if (duration <= 93) {
      return CalculationStep.weekly;
    } else if (duration <= 186) {
      return CalculationStep.monthly;
    } else {
      return CalculationStep.monthly; // Используем monthly вместо quarterly
    }
  }

  /// Получает тип периода на основе настроек
  PeriodType get periodType {
    final duration = endDate.difference(startDate).inDays;
    
    if (duration <= 31) {
      return PeriodType.month;
    } else if (duration <= 93) {
      return PeriodType.quarter;
    } else if (duration <= 186) {
      return PeriodType.halfYear;
    } else if (duration <= 366) {
      return PeriodType.year;
    } else {
      return PeriodType.custom;
    }
  }

  /// Создает период расчета на основе настроек
  CalculationPeriod toCalculationPeriod() {
    return CalculationPeriod(
      startDate: startDate,
      endDate: endDate,
      periodType: periodType,
      calculationStep: calculationStep,
    );
  }

  /// Проверяет, валидны ли настройки
  bool get isValid {
    return startDate.isBefore(endDate) && 
           endDate.difference(startDate).inDays >= 1;
  }

  /// Получает количество периодов в анализе
  int get periodsCount {
    final duration = endDate.difference(startDate).inDays;
    
    switch (calculationStep) {
      case CalculationStep.daily:
        return duration;
      case CalculationStep.weekly:
        return (duration / 7).ceil();
      case CalculationStep.monthly:
        return _monthsBetween(startDate, endDate);
    }
  }

  /// Вычисляет количество месяцев между датами
  static int _monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month + 1;
  }
}
