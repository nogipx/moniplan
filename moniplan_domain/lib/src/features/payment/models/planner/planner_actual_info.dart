// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'planner_actual_info.freezed.dart';
part 'planner_actual_info.g.dart';

@Freezed()
class PlannerActualInfo with _$PlannerActualInfo {
  const PlannerActualInfo._();

  const factory PlannerActualInfo({
    required final String plannerId,
    required final DateTime updatedAt,
    @Default(0) final int completedCount,
    @Default(0) final int waitingCount,
    @Default(0) final int disabledCount,
    @Default(0) final int totalCount,
    @Default(0) final num updatedAtBudget,
  }) = _PlannerActualInfo;

  factory PlannerActualInfo.fromJson(Map<String, dynamic> json) =>
      _$PlannerActualInfoFromJson(json);
}
