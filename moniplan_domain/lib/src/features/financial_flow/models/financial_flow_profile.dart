// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'financial_instrument.dart';

part 'financial_flow_profile.freezed.dart';
part 'financial_flow_profile.g.dart';

/// Профиль финансового потока - набор финансовых инструментов для расчета
@freezed
class FinancialFlowProfile with _$FinancialFlowProfile {
  const FinancialFlowProfile._();

  @JsonSerializable()
  const factory FinancialFlowProfile({
    /// Уникальный идентификатор профиля
    required String id,

    /// Название профиля
    required String name,

    /// Описание профиля
    @Default('') String description,

    /// Список финансовых инструментов
    @Default([]) List<FinancialInstrument> instruments,

    /// Период расчета
    required CalculationPeriod calculationPeriod,

    /// Валюта по умолчанию для расчетов
    required CurrencyData defaultCurrency,

    /// Настройки расчета
    @Default(CalculationSettings()) CalculationSettings calculationSettings,

    /// Активен ли профиль
    @Default(true) bool isActive,

    /// Дата создания
    DateTime? createdAt,

    /// Дата последнего обновления
    DateTime? updatedAt,

    /// Теги для группировки профилей
    @Default({}) Set<String> tags,

    /// Дополнительные метаданные
    @Default({}) Map<String, dynamic> metadata,
  }) = _FinancialFlowProfile;

  factory FinancialFlowProfile.fromJson(Map<String, dynamic> json) =>
      _$FinancialFlowProfileFromJson(json);

  /// Получает активные инструменты в указанную дату
  List<FinancialInstrument> getActiveInstrumentsAt(DateTime date) {
    return instruments
        .where((instrument) => instrument.isActiveAtDate(date))
        .toList();
  }

  /// Получает все инструменты определенного типа
  List<FinancialInstrument> getInstrumentsByType(FinancialInstrumentType type) {
    return instruments.where((instrument) => instrument.type == type).toList();
  }

  /// Получает все доходы
  List<FinancialInstrument> get incomes {
    return instruments.where((instrument) => instrument.type.isIncome).toList();
  }

  /// Получает все расходы
  List<FinancialInstrument> get expenses {
    return instruments
        .where((instrument) => instrument.type.isExpense)
        .toList();
  }

  /// Получает все кредиты
  List<FinancialInstrument> get credits {
    return instruments.where((instrument) => instrument.type.isCredit).toList();
  }
}

/// Период для расчета финансового потока
@freezed
class CalculationPeriod with _$CalculationPeriod {
  const CalculationPeriod._();

  @JsonSerializable()
  const factory CalculationPeriod({
    /// Дата начала периода
    required DateTime startDate,

    /// Дата окончания периода
    required DateTime endDate,

    /// Тип периода (месяц, квартал, год, произвольный)
    @Default(PeriodType.custom) PeriodType periodType,

    /// Шаг расчета (по дням, неделям, месяцам)
    @Default(CalculationStep.monthly) CalculationStep calculationStep,
  }) = _CalculationPeriod;

  factory CalculationPeriod.fromJson(Map<String, dynamic> json) =>
      _$CalculationPeriodFromJson(json);

  /// Создает период на указанное количество месяцев от текущей даты
  factory CalculationPeriod.forMonths(int months) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(
      now.year,
      now.month + months,
      1,
    ).subtract(const Duration(days: 1));

    return CalculationPeriod(
      startDate: start,
      endDate: end,
      periodType: months == 1 ? PeriodType.month : PeriodType.custom,
      calculationStep: CalculationStep.monthly,
    );
  }

  /// Создает период на текущий месяц
  factory CalculationPeriod.currentMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(
      now.year,
      now.month + 1,
      1,
    ).subtract(const Duration(days: 1));

    return CalculationPeriod(
      startDate: start,
      endDate: end,
      periodType: PeriodType.month,
      calculationStep: CalculationStep.monthly,
    );
  }

  /// Создает период на текущий квартал
  factory CalculationPeriod.currentQuarter() {
    final now = DateTime.now();
    final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
    final start = DateTime(now.year, quarterStartMonth, 1);
    final end = DateTime(
      now.year,
      quarterStartMonth + 3,
      1,
    ).subtract(const Duration(days: 1));

    return CalculationPeriod(
      startDate: start,
      endDate: end,
      periodType: PeriodType.quarter,
      calculationStep: CalculationStep.monthly,
    );
  }

  /// Возвращает длительность периода в днях
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Возвращает количество полных месяцев в периоде
  int get monthsCount {
    return ((endDate.year - startDate.year) * 12) +
        (endDate.month - startDate.month) +
        1;
  }

  /// Проверяет, попадает ли дата в период
  bool containsDate(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }
}

/// Тип периода расчета
enum PeriodType {
  /// Один месяц
  month('month', 'Месяц'),

  /// Квартал (3 месяца)
  quarter('quarter', 'Квартал'),

  /// Полгода
  halfYear('halfYear', 'Полгода'),

  /// Год
  year('year', 'Год'),

  /// Произвольный период
  custom('custom', 'Произвольный');

  const PeriodType(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Шаг расчета
enum CalculationStep {
  /// По дням
  daily('daily', 'По дням'),

  /// По неделям
  weekly('weekly', 'По неделям'),

  /// По месяцам
  monthly('monthly', 'По месяцам');

  const CalculationStep(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Настройки расчета финансового потока
@freezed
class CalculationSettings with _$CalculationSettings {
  const CalculationSettings._();

  @JsonSerializable()
  const factory CalculationSettings({
    /// Включать ли нерегулярные доходы/расходы
    @Default(true) bool includeOneTimeItems,

    /// Учитывать ли остатки по кредитам
    @Default(true) bool includeCreditBalances,

    /// Проводить ли расчет с учетом инфляции
    @Default(false) bool adjustForInflation,

    /// Процент инфляции (годовой)
    @Default(0.0) double inflationRate,

    /// Группировать ли результаты по категориям
    @Default(true) bool groupByCategories,

    /// Показывать ли промежуточные итоги
    @Default(true) bool showIntermediateResults,

    /// Округлять ли суммы
    @Default(true) bool roundAmounts,

    /// Количество знаков после запятой для округления
    @Default(2) int decimalPlaces,
  }) = _CalculationSettings;

  factory CalculationSettings.fromJson(Map<String, dynamic> json) =>
      _$CalculationSettingsFromJson(json);
}
