// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_core/moniplan_core.dart';

class PlannerActualInfoMapper
    implements IMapper<PlannerActualInfo, PlannerActualInfoDriftTableData> {
  const PlannerActualInfoMapper();

  @override
  PlannerActualInfo toDomain(PlannerActualInfoDriftTableData data) {
    return PlannerActualInfo(
      plannerId: data.plannerId,
      updatedAt: data.updatedAt,
      completedCount: data.completedCount,
      waitingCount: data.waitingCount,
      disabledCount: data.disabledCount,
      totalCount: data.totalCount,
      updatedAtBudget: data.updatedAtBudget,
    );
  }

  @override
  PlannerActualInfoDriftTableData toDto(PlannerActualInfo data) {
    return PlannerActualInfoDriftTableData(
      plannerId: data.plannerId,
      updatedAt: data.updatedAt,
      completedCount: data.completedCount,
      waitingCount: data.waitingCount,
      disabledCount: data.disabledCount,
      totalCount: data.totalCount,
      updatedAtBudget: data.updatedAtBudget.toDouble(),
    );
  }
}
