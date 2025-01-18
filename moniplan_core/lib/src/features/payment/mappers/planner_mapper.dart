// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_core/moniplan_core.dart';

class PlannerMapperDrift implements IMapper<Planner, PaymentPlannersDriftTableData> {
  const PlannerMapperDrift();

  @override
  Planner toDomain(PaymentPlannersDriftTableData data) {
    final paymentId = data.plannerId;
    final start = data.dateStart;
    final end = data.dateEnd;

    if (start == null || end == null) {
      throw Exception('Cannot compose Planner');
    }

    return Planner(
      id: paymentId,
      name: data.plannerName,
      dateStart: start,
      dateEnd: end,
      initialBudget: data.initialBudget,
      isGenerationAllowed: data.isGenerationAllowed,
    );
  }

  @override
  PaymentPlannersDriftTableData toDto(Planner data) {
    final dto = PaymentPlannersDriftTableData(
      plannerId: data.id,
      plannerName: data.name,
      dateStart: data.dateStart,
      dateEnd: data.dateEnd,
      initialBudget: data.initialBudget.toDouble(),
      isGenerationAllowed: data.isGenerationAllowed,
    );
    return dto;
  }
}
