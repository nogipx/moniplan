import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import '_index.dart';

part 'planner.freezed.dart';
part 'planner.g.dart';

@Freezed()
class Planner with _$Planner {
  const Planner._();

  const factory Planner({
    required final String id,
    required final DateTime dateStart,
    required final DateTime dateEnd,
    required final bool isGenerationAllowed,
    @Default([]) final List<Payment> payments,
    @Default(0) final num initialBudget,
    final PlannerActualInfo? actualInfo,
  }) = _Planner;

  factory Planner.fromJson(Map<String, dynamic> json) => _$PlannerFromJson(json);

  num get currentBudget => actualInfo?.updatedAtBudget ?? 0;

  int get countDonePayments => actualInfo?.completedCount ?? 0;
  int get countWaitingPayments => actualInfo?.waitingCount ?? 0;
  int get countDisabledPayments => actualInfo?.disabledCount ?? 0;
}
