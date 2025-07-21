// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import '../services/planner_integration_service.dart';
import '../models/financial_flow_calculation.dart';
import '../models/financial_flow_profile.dart';
import '../../payment/models/planner/planner.dart';

/// Use case для анализа финансового потока планировщика
class AnalyzePlannerFinancialFlowUseCase {
  final PlannerFinancialFlowService _plannerFlowService;

  AnalyzePlannerFinancialFlowUseCase(this._plannerFlowService);

  /// Анализирует финансовый поток для указанного планировщика
  Future<FinancialFlowCalculation> execute(
    String plannerId, {
    CalculationSettings? settings,
  }) async {
    return await _plannerFlowService.analyzeFinancialFlow(
      plannerId,
      settings: settings,
    );
  }

  /// Получает краткую сводку финансового потока
  Future<FlowSummary> getSummary(String plannerId) async {
    return await _plannerFlowService.getFlowSummary(plannerId);
  }

  /// Сравнивает финансовые потоки нескольких планировщиков
  Future<List<FlowComparison>> comparePlannersFlow(
    List<String> plannerIds,
  ) async {
    return await _plannerFlowService.comparePlanners(plannerIds);
  }

  /// Получает рекомендации по оптимизации
  Future<List<FlowRecommendation>> getOptimizationRecommendations(
    String plannerId,
  ) async {
    return await _plannerFlowService.getOptimizationRecommendations(plannerId);
  }
}

/// Use case для создания профилей финансового потока из планировщиков
class CreateFinancialFlowProfileFromPlannerUseCase {
  final PaymentToFinancialInstrumentAdapter _adapter;

  CreateFinancialFlowProfileFromPlannerUseCase(this._adapter);

  /// Создает профиль финансового потока из планировщика
  FinancialFlowProfile execute(
    Planner planner, {
    CalculationSettings? calculationSettings,
    Set<String> tags = const {},
  }) {
    return _adapter.createProfileFromPlanner(
      planner,
      calculationSettings: calculationSettings,
      tags: tags,
    );
  }

  /// Создает профили из списка планировщиков
  List<FinancialFlowProfile> executeForMultiple(
    List<Planner> planners, {
    CalculationSettings? calculationSettings,
    Set<String> tags = const {},
  }) {
    return planners
        .map(
          (planner) => execute(
            planner,
            calculationSettings: calculationSettings,
            tags: tags,
          ),
        )
        .toList();
  }
}
