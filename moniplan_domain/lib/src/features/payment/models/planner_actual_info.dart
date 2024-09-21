import 'package:freezed_annotation/freezed_annotation.dart';

part 'planner_actual_info.freezed.dart';

@Freezed()
class PlannerActualInfo with _$PlannerActualInfo {
  const PlannerActualInfo._();

  const factory PlannerActualInfo({
    required final String plannerId,
    required final DateTime updatedAt,
    required final int completedCount,
    required final int waitingCount,
    required final int disabledCount,
    required final int totalCount,
    @Default([]) final List<num> budgetSeries,
  }) = _PlannerActualInfo;
}
