// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:moniplan_domain/src/_index.dart';

import '../models/financial_instrument.dart';
import '../models/financial_flow_profile.dart';
import '../models/financial_flow_calculation.dart';

/// Сервис для расчета финансового потока
abstract class FinancialFlowCalculationService {
  /// Выполняет расчет финансового потока для профиля
  Future<FinancialFlowCalculation> calculateFinancialFlow(
    FinancialFlowProfile profile,
  );

  /// Выполняет быстрый расчет для одного периода
  Future<PeriodCalculationResult> calculatePeriod(
    FinancialFlowProfile profile,
    CalculationPeriod period,
  );

  /// Рассчитывает остаток по кредиту на определенную дату
  num calculateCreditBalance(
    FinancialInstrument creditInstrument,
    DateTime date,
  );

  /// Проверяет валидность профиля для расчета
  List<String> validateProfile(FinancialFlowProfile profile);
}

/// Реализация сервиса расчета финансового потока
class FinancialFlowCalculationServiceImpl
    implements FinancialFlowCalculationService {
  @override
  Future<FinancialFlowCalculation> calculateFinancialFlow(
    FinancialFlowProfile profile,
  ) async {
    final stopwatch = Stopwatch()..start();
    final calculationId = _generateId();

    try {
      // Валидация профиля
      final errors = validateProfile(profile);
      if (errors.isNotEmpty) {
        return FinancialFlowCalculation(
          id: calculationId,
          profile: profile,
          calculatedAt: DateTime.now(),
          status: CalculationStatus.error,
          errors: errors,
          summary: CalculationSummary(currency: profile.defaultCurrency),
          executionTimeMs: stopwatch.elapsedMilliseconds,
        );
      }

      // Генерируем периоды для расчета
      final periods = _generateCalculationPeriods(profile.calculationPeriod);
      final periodResults = <PeriodCalculationResult>[];

      // Рассчитываем каждый период
      for (final period in periods) {
        final periodResult = await calculatePeriod(profile, period);
        periodResults.add(periodResult);
      }

      // Создаем общий итог
      final summary = _createSummary(periodResults, profile.defaultCurrency);

      stopwatch.stop();

      return FinancialFlowCalculation(
        id: calculationId,
        profile: profile,
        calculatedAt: DateTime.now(),
        periodResults: periodResults,
        summary: summary,
        status: CalculationStatus.completed,
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      return FinancialFlowCalculation(
        id: calculationId,
        profile: profile,
        calculatedAt: DateTime.now(),
        status: CalculationStatus.error,
        errors: ['Ошибка расчета: ${e.toString()}'],
        summary: CalculationSummary(currency: profile.defaultCurrency),
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  @override
  Future<PeriodCalculationResult> calculatePeriod(
    FinancialFlowProfile profile,
    CalculationPeriod period,
  ) async {
    final instrumentResults = <InstrumentCalculationResult>[];
    final categoryResults = <String, num>{};
    final creditBalances = <String, num>{};

    num totalIncome = 0;
    num totalExpenses = 0;

    // Получаем активные инструменты для этого периода
    final activeInstruments =
        profile.instruments
            .where(
              (instrument) => _isInstrumentActiveInPeriod(instrument, period),
            )
            .toList();

    // Рассчитываем каждый инструмент
    for (final instrument in activeInstruments) {
      final instrumentResult = _calculateInstrumentForPeriod(
        instrument,
        period,
      );
      instrumentResults.add(instrumentResult);

      // Обновляем общие суммы
      if (instrument.type.isIncome) {
        totalIncome += instrumentResult.calculatedAmount.abs();
      } else if (instrument.type.isExpense) {
        totalExpenses += instrumentResult.calculatedAmount.abs();
      }

      // Обновляем результаты по категориям
      for (final tag in instrument.tags) {
        categoryResults[tag] =
            (categoryResults[tag] ?? 0) + instrumentResult.calculatedAmount;
      }

      // Обновляем остатки по кредитам
      if (instrument.type.isCredit && instrumentResult.creditBalance != null) {
        creditBalances[instrument.id] = instrumentResult.creditBalance!;
      }
    }

    return PeriodCalculationResult(
      period: period,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netFlow: totalIncome - totalExpenses,
      instrumentResults: instrumentResults,
      categoryResults: categoryResults,
      creditBalances: creditBalances,
      currency: profile.defaultCurrency,
    );
  }

  @override
  num calculateCreditBalance(
    FinancialInstrument creditInstrument,
    DateTime date,
  ) {
    if (!creditInstrument.type.isCredit ||
        creditInstrument.creditData == null) {
      return 0;
    }

    return creditInstrument.creditData!.calculateRemainingAmount(date);
  }

  @override
  List<String> validateProfile(FinancialFlowProfile profile) {
    final errors = <String>[];

    if (profile.instruments.isEmpty) {
      errors.add('Профиль должен содержать хотя бы один финансовый инструмент');
    }

    // Проверяем валидность дат
    if (profile.calculationPeriod.startDate.isAfter(
      profile.calculationPeriod.endDate,
    )) {
      errors.add('Дата начала периода не может быть позже даты окончания');
    }

    // Проверяем инструменты
    for (final instrument in profile.instruments) {
      final instrumentErrors = _validateInstrument(instrument);
      errors.addAll(instrumentErrors);
    }

    return errors;
  }

  /// Проверяет, активен ли инструмент в указанном периоде
  bool _isInstrumentActiveInPeriod(
    FinancialInstrument instrument,
    CalculationPeriod period,
  ) {
    if (!instrument.isActive) return false;

    // Проверяем пересечение периодов
    final instrumentStart = instrument.startDate ?? DateTime(1900);
    final instrumentEnd = instrument.endDate ?? DateTime(2100);

    return instrumentStart.isBefore(
          period.endDate.add(const Duration(days: 1)),
        ) &&
        instrumentEnd.isAfter(
          period.startDate.subtract(const Duration(days: 1)),
        );
  }

  /// Рассчитывает инструмент для указанного периода
  InstrumentCalculationResult _calculateInstrumentForPeriod(
    FinancialInstrument instrument,
    CalculationPeriod period,
  ) {
    final subPeriodResults = <SubPeriodResult>[];
    num totalCalculatedAmount = 0;
    int applicationsCount = 0;

    // Определяем даты для расчета в зависимости от шага
    final calculationDates = _getCalculationDates(period);

    for (final date in calculationDates) {
      if (instrument.isActiveAtDate(date)) {
        num periodAmount = 0;

        // Рассчитываем сумму в зависимости от типа инструмента
        if (instrument.repeat.type == DateTimeRepeatType.none) {
          // Разовый платеж - применяется только один раз
          if (applicationsCount == 0 &&
              (instrument.startDate == null ||
                  date.isAfter(
                    instrument.startDate!.subtract(const Duration(days: 1)),
                  ))) {
            periodAmount = instrument.normalizedAmount;
            applicationsCount = 1;
          }
        } else {
          // Регулярный платеж - проверяем соответствие повторению
          if (_shouldApplyOnDate(instrument, date)) {
            periodAmount = instrument.monthlyAmount;
            applicationsCount++;
          }
        }

        totalCalculatedAmount += periodAmount;

        // Рассчитываем остаток по кредиту, если применимо
        num? creditBalance;
        if (instrument.type.isCredit) {
          creditBalance = calculateCreditBalance(instrument, date);
        }

        subPeriodResults.add(
          SubPeriodResult(
            date: date,
            amount: periodAmount,
            wasActive: true,
            creditBalance: creditBalance,
          ),
        );
      }
    }

    // Финальный остаток по кредиту
    num? finalCreditBalance;
    if (instrument.type.isCredit) {
      finalCreditBalance = calculateCreditBalance(instrument, period.endDate);
    }

    return InstrumentCalculationResult(
      instrumentId: instrument.id,
      instrumentName: instrument.name,
      instrumentType: instrument.type,
      calculatedAmount: totalCalculatedAmount,
      originalAmount: instrument.amount,
      applicationsCount: applicationsCount,
      creditBalance: finalCreditBalance,
      subPeriodResults: subPeriodResults,
    );
  }

  /// Генерирует даты для расчета в зависимости от шага
  List<DateTime> _getCalculationDates(CalculationPeriod period) {
    final dates = <DateTime>[];
    var currentDate = period.startDate;

    while (currentDate.isBefore(period.endDate.add(const Duration(days: 1)))) {
      dates.add(currentDate);

      switch (period.calculationStep) {
        case CalculationStep.daily:
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case CalculationStep.weekly:
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case CalculationStep.monthly:
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + 1,
            currentDate.day,
          );
          break;
      }
    }

    return dates;
  }

  /// Проверяет, должен ли инструмент применяться в указанную дату
  bool _shouldApplyOnDate(FinancialInstrument instrument, DateTime date) {
    // Упрощенная логика - для полной реализации нужно учитывать repeat
    return true; // Пока применяем на каждую дату расчета
  }

  /// Генерирует периоды для расчета
  List<CalculationPeriod> _generateCalculationPeriods(
    CalculationPeriod mainPeriod,
  ) {
    if (mainPeriod.calculationStep == CalculationStep.monthly) {
      // Разбиваем на месячные периоды
      final periods = <CalculationPeriod>[];
      var currentStart = mainPeriod.startDate;

      while (currentStart.isBefore(mainPeriod.endDate)) {
        final currentEnd = DateTime(
          currentStart.year,
          currentStart.month + 1,
          1,
        ).subtract(const Duration(days: 1));

        final actualEnd =
            currentEnd.isAfter(mainPeriod.endDate)
                ? mainPeriod.endDate
                : currentEnd;

        periods.add(
          CalculationPeriod(
            startDate: currentStart,
            endDate: actualEnd,
            periodType: PeriodType.month,
            calculationStep: mainPeriod.calculationStep,
          ),
        );

        currentStart = DateTime(currentStart.year, currentStart.month + 1, 1);
      }

      return periods;
    }

    // Для других шагов возвращаем исходный период
    return [mainPeriod];
  }

  /// Создает общий итог расчета
  CalculationSummary _createSummary(
    List<PeriodCalculationResult> periodResults,
    dynamic defaultCurrency,
  ) {
    if (periodResults.isEmpty) {
      return CalculationSummary(currency: defaultCurrency);
    }

    final totalIncome = periodResults
        .map((r) => r.totalIncome)
        .reduce((a, b) => a + b);

    final totalExpenses = periodResults
        .map((r) => r.totalExpenses)
        .reduce((a, b) => a + b);

    final totalNetFlow = periodResults
        .map((r) => r.netFlow)
        .reduce((a, b) => a + b);

    final totalCreditPayments = periodResults
        .expand((r) => r.instrumentResults)
        .where((ir) => ir.instrumentType.isCredit)
        .map((ir) => ir.calculatedAmount.abs())
        .fold(0.0, (a, b) => a + b);

    final totalRemainingBalance =
        periodResults.isNotEmpty
            ? periodResults.last.creditBalances.values.fold(
              0.0,
              (a, b) => a + b,
            )
            : 0.0;

    return CalculationSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      averageMonthlyIncome: totalIncome / periodResults.length,
      averageMonthlyExpenses: totalExpenses / periodResults.length,
      totalNetFlow: totalNetFlow,
      averageMonthlyNetFlow: totalNetFlow / periodResults.length,
      totalCreditPayments: totalCreditPayments,
      totalRemainingCreditBalance: totalRemainingBalance,
      currency: defaultCurrency,
      periodsCount: periodResults.length,
    );
  }

  /// Валидирует отдельный инструмент
  List<String> _validateInstrument(FinancialInstrument instrument) {
    final errors = <String>[];

    if (instrument.name.trim().isEmpty) {
      errors.add('Инструмент "${instrument.id}" должен иметь название');
    }

    if (instrument.amount < 0 && !instrument.type.isExpense) {
      errors.add(
        'Инструмент "${instrument.name}" не может иметь отрицательную сумму',
      );
    }

    if (instrument.type.isCredit && instrument.creditData == null) {
      errors.add(
        'Кредитный инструмент "${instrument.name}" должен содержать данные о кредите',
      );
    }

    if (instrument.creditData != null) {
      final creditErrors = _validateCreditData(
        instrument.creditData!,
        instrument.name,
      );
      errors.addAll(creditErrors);
    }

    return errors;
  }

  /// Валидирует данные кредита
  List<String> _validateCreditData(
    CreditData creditData,
    String instrumentName,
  ) {
    final errors = <String>[];

    if (creditData.totalAmount <= 0) {
      errors.add(
        'Кредит "$instrumentName" должен иметь положительную общую сумму',
      );
    }

    if (creditData.monthlyPayment <= 0) {
      errors.add(
        'Кредит "$instrumentName" должен иметь положительный ежемесячный платеж',
      );
    }

    if (creditData.interestRate < 0 || creditData.interestRate > 100) {
      errors.add(
        'Процентная ставка кредита "$instrumentName" должна быть от 0 до 100%',
      );
    }

    if (creditData.termMonths <= 0) {
      errors.add('Срок кредита "$instrumentName" должен быть положительным');
    }

    return errors;
  }

  /// Генерирует уникальный идентификатор
  String _generateId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(9999);
    return 'calc_${timestamp}_$randomNum';
  }
}
