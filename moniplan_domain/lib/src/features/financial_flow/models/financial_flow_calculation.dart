// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'financial_instrument.dart';
import 'financial_flow_profile.dart';

part 'financial_flow_calculation.freezed.dart';
part 'financial_flow_calculation.g.dart';

/// Результат расчета финансового потока
@freezed
class FinancialFlowCalculation with _$FinancialFlowCalculation {
  const FinancialFlowCalculation._();

  @JsonSerializable()
  const factory FinancialFlowCalculation({
    /// Уникальный идентификатор расчета
    required String id,
    
    /// Профиль, по которому производился расчет
    required FinancialFlowProfile profile,
    
    /// Дата и время расчета
    required DateTime calculatedAt,
    
    /// Результаты по периодам
    @Default([]) List<PeriodCalculationResult> periodResults,
    
    /// Общие итоги
    required CalculationSummary summary,
    
    /// Статус расчета
    @Default(CalculationStatus.completed) CalculationStatus status,
    
    /// Ошибки, если они есть
    @Default([]) List<String> errors,
    
    /// Время выполнения расчета в миллисекундах
    @Default(0) int executionTimeMs,
  }) = _FinancialFlowCalculation;

  factory FinancialFlowCalculation.fromJson(Map<String, dynamic> json) => 
      _$FinancialFlowCalculationFromJson(json);

  /// Получает результат для конкретного периода
  PeriodCalculationResult? getResultForPeriod(DateTime date) {
    return periodResults
        .where((result) => result.period.containsDate(date))
        .firstOrNull;
  }
  
  /// Получает результаты в указанном диапазоне дат
  List<PeriodCalculationResult> getResultsInRange(DateTime start, DateTime end) {
    return periodResults
        .where((result) => 
            result.period.startDate.isAfter(start.subtract(const Duration(days: 1))) &&
            result.period.endDate.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }
}

/// Результат расчета для одного периода
@freezed
class PeriodCalculationResult with _$PeriodCalculationResult {
  const PeriodCalculationResult._();

  @JsonSerializable()
  const factory PeriodCalculationResult({
    /// Период расчета
    required CalculationPeriod period,
    
    /// Общий доход за период
    @Default(0) num totalIncome,
    
    /// Общие расходы за период
    @Default(0) num totalExpenses,
    
    /// Чистый поток (доходы - расходы)
    @Default(0) num netFlow,
    
    /// Результаты по инструментам
    @Default([]) List<InstrumentCalculationResult> instrumentResults,
    
    /// Результаты по категориям
    @Default({}) Map<String, num> categoryResults,
    
    /// Остатки по кредитам на конец периода
    @Default({}) Map<String, num> creditBalances,
    
    /// Валюта расчета
    required CurrencyData currency,
  }) = _PeriodCalculationResult;

  factory PeriodCalculationResult.fromJson(Map<String, dynamic> json) => 
      _$PeriodCalculationResultFromJson(json);

  /// Получает результат для конкретного инструмента
  InstrumentCalculationResult? getResultForInstrument(String instrumentId) {
    return instrumentResults
        .where((result) => result.instrumentId == instrumentId)
        .firstOrNull;
  }
  
  /// Получает результаты по типу инструмента
  List<InstrumentCalculationResult> getResultsByType(FinancialInstrumentType type) {
    return instrumentResults
        .where((result) => result.instrumentType == type)
        .toList();
  }
}

/// Результат расчета для одного финансового инструмента
@freezed
class InstrumentCalculationResult with _$InstrumentCalculationResult {
  const InstrumentCalculationResult._();

  @JsonSerializable()
  const factory InstrumentCalculationResult({
    /// Идентификатор инструмента
    required String instrumentId,
    
    /// Название инструмента
    required String instrumentName,
    
    /// Тип инструмента
    required FinancialInstrumentType instrumentType,
    
    /// Рассчитанная сумма за период
    @Default(0) num calculatedAmount,
    
    /// Первоначальная сумма инструмента
    @Default(0) num originalAmount,
    
    /// Количество применений за период (для регулярных платежей)
    @Default(0) int applicationsCount,
    
    /// Остаток по кредиту (если применимо)
    num? creditBalance,
    
    /// Детали расчета по дням/неделям/месяцам
    @Default([]) List<SubPeriodResult> subPeriodResults,
    
    /// Дополнительные данные
    @Default({}) Map<String, dynamic> metadata,
  }) = _InstrumentCalculationResult;

  factory InstrumentCalculationResult.fromJson(Map<String, dynamic> json) => 
      _$InstrumentCalculationResultFromJson(json);
}

/// Результат для подпериода (день, неделя, месяц)
@freezed
class SubPeriodResult with _$SubPeriodResult {
  const SubPeriodResult._();

  @JsonSerializable()
  const factory SubPeriodResult({
    /// Дата подпериода
    required DateTime date,
    
    /// Сумма за подпериод
    @Default(0) num amount,
    
    /// Был ли инструмент активен в этот период
    @Default(true) bool wasActive,
    
    /// Остаток по кредиту на эту дату (если применимо)
    num? creditBalance,
  }) = _SubPeriodResult;

  factory SubPeriodResult.fromJson(Map<String, dynamic> json) => 
      _$SubPeriodResultFromJson(json);
}

/// Общий итог расчета
@freezed
class CalculationSummary with _$CalculationSummary {
  const CalculationSummary._();

  @JsonSerializable()
  const factory CalculationSummary({
    /// Общий доход за весь период
    @Default(0) num totalIncome,
    
    /// Общие расходы за весь период
    @Default(0) num totalExpenses,
    
    /// Средний месячный доход
    @Default(0) num averageMonthlyIncome,
    
    /// Средние месячные расходы
    @Default(0) num averageMonthlyExpenses,
    
    /// Чистый поток за весь период
    @Default(0) num totalNetFlow,
    
    /// Средний месячный чистый поток
    @Default(0) num averageMonthlyNetFlow,
    
    /// Общая сумма кредитов
    @Default(0) num totalCreditAmount,
    
    /// Общие платежи по кредитам за период
    @Default(0) num totalCreditPayments,
    
    /// Остаток по всем кредитам на конец периода
    @Default(0) num totalRemainingCreditBalance,
    
    /// Валюта расчета
    required CurrencyData currency,
    
    /// Количество проанализированных периодов
    @Default(0) int periodsCount,
    
    /// Дополнительная статистика
    @Default({}) Map<String, num> additionalStats,
  }) = _CalculationSummary;

  factory CalculationSummary.fromJson(Map<String, dynamic> json) => 
      _$CalculationSummaryFromJson(json);
}

/// Статус расчета
enum CalculationStatus {
  /// В процессе
  inProgress('inProgress', 'В процессе'),
  
  /// Завершено успешно
  completed('completed', 'Завершено'),
  
  /// Завершено с предупреждениями
  completedWithWarnings('completedWithWarnings', 'Завершено с предупреждениями'),
  
  /// Ошибка
  error('error', 'Ошибка'),
  
  /// Отменено
  cancelled('cancelled', 'Отменено');

  const CalculationStatus(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  bool get isSuccessful => this == completed || this == completedWithWarnings;
  bool get hasErrors => this == error;
  bool get isFinished => this != inProgress;
}
