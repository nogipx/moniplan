import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'operations_manager_event.freezed.dart';
part 'operations_manager_event.g.dart';

@freezed
class OperationsManagerEvent with _$OperationsManagerEvent {
  const OperationsManagerEvent._();

  @JsonSerializable()
  const factory OperationsManagerEvent.computeBudget({
    @Default(IListConst([])) Iterable<Operation> operations,
    double? initialBudget,
    required DateTime startPeriod,
    required DateTime endPeriod,
  }) = OperationsManagerComputeBudgetEvent;

  factory OperationsManagerEvent.fromJson(Map<String, dynamic> json) =>
      _$OperationsManagerEventFromJson(json);
}
