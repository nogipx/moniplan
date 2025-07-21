// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import '../models/financial_instrument.dart';
import '../models/financial_flow_profile.dart';
import '../models/financial_flow_calculation.dart';
import 'financial_flow_calculation_service.dart';
import '../../payment/models/payment/payment.dart';
import '../../payment/models/planner/planner.dart';
import '../../payment/models/payment/payment_type.dart';
import '../../payment/repo/i_payment_planner_repo.dart';
import '../../_common/models/currency_data/currency_data_common.dart';

/// Адаптер для преобразования Payment в FinancialInstrument
class PaymentToFinancialInstrumentAdapter {
  /// Преобразует Payment в FinancialInstrument
  FinancialInstrument adaptPayment(Payment payment) {
    return FinancialInstrument(
      id: payment.paymentId,
      name: payment.details.name,
      description: payment.details.note,
      type: _mapPaymentTypeToInstrumentType(payment.details.type),
      currency: payment.details.currency,
      amount: payment.details.money.abs(), // Используем изначальную положительную сумму
      tags: payment.details.tags,
      isActive: payment.isEnabled,
      repeat: payment.repeat,
      startDate: payment.dateStart,
      endDate: payment.dateEnd,
      // Кредитные данные пока не поддерживаются в Payment, будут null
      creditData: null,
    );
  }

  /// Преобразует список платежей в список финансовых инструментов
  List<FinancialInstrument> adaptPayments(List<Payment> payments) {
    return payments.map(adaptPayment).toList();
  }

  /// Создает профиль финансового потока из планировщика
  FinancialFlowProfile createProfileFromPlanner(
    Planner planner, {
    CalculationSettings? calculationSettings,
    Set<String> tags = const {},
  }) {
    // Определяем валюту по умолчанию из первого платежа или используем RUB
    final defaultCurrency =
        planner.payments.isNotEmpty
            ? planner.payments.first.details.currency
            : CurrencyDataCommon.rub;

    // Создаем период расчета на основе дат планировщика
    final calculationPeriod = CalculationPeriod(
      startDate: planner.dateStart,
      endDate: planner.dateEnd,
      periodType: _determinePeriodType(planner.dateStart, planner.dateEnd),
      calculationStep: CalculationStep.monthly,
    );

    // Преобразуем платежи в финансовые инструменты
    final instruments = adaptPayments(planner.payments);

    return FinancialFlowProfile(
      id: 'flow_${planner.id}',
      name:
          'Финансовый поток: ${planner.name.isNotEmpty ? planner.name : 'Планировщик'}',
      description:
          'Автоматически созданный профиль на основе планировщика ${planner.id}',
      instruments: instruments,
      calculationPeriod: calculationPeriod,
      defaultCurrency: defaultCurrency,
      calculationSettings: calculationSettings ?? const CalculationSettings(),
      tags: {...tags, 'planner', 'auto-generated'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        'source_planner_id': planner.id,
        'initial_budget': planner.initialBudget.toString(),
      },
    );
  }

  /// Преобразует тип платежа в тип финансового инструмента
  FinancialInstrumentType _mapPaymentTypeToInstrumentType(
    PaymentType paymentType,
  ) {
    switch (paymentType) {
      case PaymentType.income:
        return FinancialInstrumentType.regularIncome;
      case PaymentType.expense:
        return FinancialInstrumentType.regularExpense;
      case PaymentType.correction:
        // Коррекции можно рассматривать как разовые доходы/расходы
        return FinancialInstrumentType.oneTimeIncome;
      case PaymentType.unknown:
        return FinancialInstrumentType.oneTimeIncome;
    }
  }

  /// Определяет тип периода на основе дат
  PeriodType _determinePeriodType(DateTime startDate, DateTime endDate) {
    final durationInDays = endDate.difference(startDate).inDays;

    if (durationInDays <= 31) {
      return PeriodType.month;
    } else if (durationInDays <= 93) {
      return PeriodType.quarter;
    } else if (durationInDays <= 186) {
      return PeriodType.halfYear;
    } else if (durationInDays <= 366) {
      return PeriodType.year;
    } else {
      return PeriodType.custom;
    }
  }
}

/// Интегрированный сервис финансового потока для работы с планировщиком
class PlannerFinancialFlowService {
  final PaymentToFinancialInstrumentAdapter _adapter;
  final FinancialFlowCalculationService _calculationService;
  final IPlannerRepo _plannerRepo;

  PlannerFinancialFlowService(
    this._adapter,
    this._calculationService,
    this._plannerRepo,
  );

  /// Анализирует финансовый поток для планировщика
  Future<FinancialFlowCalculation> analyzeFinancialFlow(
    String plannerId, {
    CalculationSettings? settings,
  }) async {
    // Получаем планировщик с платежами
    final planner = await _plannerRepo.getPlannerById(plannerId);
    if (planner == null) {
      throw Exception('Planner not found: $plannerId');
    }

    // Получаем платежи планировщика
    final payments = await _plannerRepo.getPaymentsByPlannerId(
      plannerId: plannerId,
    );
    final plannerWithPayments = planner.copyWith(payments: payments);

    // Создаем профиль финансового потока
    final profile = _adapter.createProfileFromPlanner(
      plannerWithPayments,
      calculationSettings: settings,
    );

    // Выполняем расчет
    return await _calculationService.calculateFinancialFlow(profile);
  }

  /// Получает краткую сводку финансового потока для планировщика
  Future<FlowSummary> getFlowSummary(String plannerId) async {
    final calculation = await analyzeFinancialFlow(plannerId);

    return FlowSummary(
      plannerId: plannerId,
      totalIncome: calculation.summary.totalIncome,
      totalExpenses: calculation.summary.totalExpenses,
      netFlow: calculation.summary.totalNetFlow,
      averageMonthlyIncome: calculation.summary.averageMonthlyIncome,
      averageMonthlyExpenses: calculation.summary.averageMonthlyExpenses,
      averageMonthlyNetFlow: calculation.summary.averageMonthlyNetFlow,
      periodsCount: calculation.summary.periodsCount,
      calculatedAt: calculation.calculatedAt,
    );
  }

  /// Сравнивает финансовые потоки нескольких планировщиков
  Future<List<FlowComparison>> comparePlanners(List<String> plannerIds) async {
    final comparisons = <FlowComparison>[];

    for (final plannerId in plannerIds) {
      try {
        final summary = await getFlowSummary(plannerId);
        final planner = await _plannerRepo.getPlannerById(plannerId);

        comparisons.add(
          FlowComparison(
            plannerId: plannerId,
            plannerName: planner?.name ?? 'Неизвестный планировщик',
            summary: summary,
          ),
        );
      } catch (e) {
        // Пропускаем планировщики с ошибками
        continue;
      }
    }

    return comparisons;
  }

  /// Получает рекомендации по оптимизации финансового потока
  Future<List<FlowRecommendation>> getOptimizationRecommendations(
    String plannerId,
  ) async {
    final calculation = await analyzeFinancialFlow(plannerId);
    final recommendations = <FlowRecommendation>[];

    // Анализируем общий поток
    if (calculation.summary.totalNetFlow < 0) {
      recommendations.add(
        FlowRecommendation(
          type: RecommendationType.warning,
          title: 'Отрицательный денежный поток',
          description:
              'Расходы превышают доходы на ${(-calculation.summary.totalNetFlow).toStringAsFixed(0)} ₽',
          priority: RecommendationPriority.high,
        ),
      );
    }

    // Анализируем регулярность доходов
    final incomeInstruments = calculation.profile.incomes;
    if (incomeInstruments.length < 2) {
      recommendations.add(
        FlowRecommendation(
          type: RecommendationType.info,
          title: 'Единственный источник дохода',
          description:
              'Рассмотрите возможность диверсификации источников дохода',
          priority: RecommendationPriority.medium,
        ),
      );
    }

    // Анализируем крупные расходы
    final expenseInstruments = calculation.profile.expenses;
    final totalExpenses = calculation.summary.totalExpenses;

    for (final expense in expenseInstruments) {
      final expenseShare = (expense.amount / totalExpenses) * 100;
      if (expenseShare > 30) {
        recommendations.add(
          FlowRecommendation(
            type: RecommendationType.warning,
            title: 'Крупная статья расходов',
            description:
                '${expense.name} составляет ${expenseShare.toStringAsFixed(1)}% от всех расходов',
            priority: RecommendationPriority.medium,
          ),
        );
      }
    }

    // Анализируем сезонность
    if (calculation.periodResults.length >= 3) {
      final flows = calculation.periodResults.map((r) => r.netFlow).toList();
      final avgFlow = flows.reduce((a, b) => a + b) / flows.length;
      final volatility = _calculateVolatility(flows, avgFlow);

      if (volatility > avgFlow * 0.5) {
        recommendations.add(
          FlowRecommendation(
            type: RecommendationType.info,
            title: 'Высокая волатильность потока',
            description:
                'Рассмотрите создание резервного фонда для сглаживания колебаний',
            priority: RecommendationPriority.low,
          ),
        );
      }
    }

    return recommendations;
  }

  /// Вычисляет волатильность значений
  double _calculateVolatility(List<num> values, num average) {
    if (values.isEmpty) return 0;

    final sumSquaredDiffs = values
        .map((value) => (value - average) * (value - average))
        .reduce((a, b) => a + b);

    return math.sqrt(sumSquaredDiffs / values.length);
  }
}

/// Краткая сводка финансового потока
class FlowSummary {
  final String plannerId;
  final num totalIncome;
  final num totalExpenses;
  final num netFlow;
  final num averageMonthlyIncome;
  final num averageMonthlyExpenses;
  final num averageMonthlyNetFlow;
  final int periodsCount;
  final DateTime calculatedAt;

  FlowSummary({
    required this.plannerId,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netFlow,
    required this.averageMonthlyIncome,
    required this.averageMonthlyExpenses,
    required this.averageMonthlyNetFlow,
    required this.periodsCount,
    required this.calculatedAt,
  });
}

/// Сравнение финансовых потоков
class FlowComparison {
  final String plannerId;
  final String plannerName;
  final FlowSummary summary;

  FlowComparison({
    required this.plannerId,
    required this.plannerName,
    required this.summary,
  });
}

/// Рекомендация по оптимизации финансового потока
class FlowRecommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final RecommendationPriority priority;

  FlowRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
  });
}

/// Тип рекомендации
enum RecommendationType { info, warning, success }

/// Приоритет рекомендации
enum RecommendationPriority { low, medium, high }
