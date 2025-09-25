import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_app/core/_index.dart';

part 'planner.freezed.dart';
part 'planner.g.dart';

@Freezed()
abstract class Planner with _$Planner {
  const factory Planner({
    required final String id,
    required final DateTime dateStart,
    required final DateTime dateEnd,
    required final bool isGenerationAllowed,
    @Default('') final String name,
    @Default([]) final List<Payment> payments,
    @Default(0) final num initialBudget,
    final PlannerActualInfo? actualInfo,
  }) = _Planner;
  const Planner._();

  factory Planner.fromJson(Map<String, dynamic> json) => _$PlannerFromJson(json);

  num get currentBudget => actualInfo?.updatedAtBudget ?? 0;

  int get countDonePayments => actualInfo?.completedCount ?? 0;
  int get countWaitingPayments => actualInfo?.waitingCount ?? 0;
  int get countDisabledPayments => actualInfo?.disabledCount ?? 0;
}
