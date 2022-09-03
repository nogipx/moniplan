import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'operations_manager_event.freezed.dart';

@freezed
class OperationsManagerEvent with _$OperationsManagerEvent {
  const OperationsManagerEvent._();

  const factory OperationsManagerEvent.computeBudget({
    @Default(IListConst([])) Iterable<Operation> operations,
    DateTime? startPeriod,
    DateTime? endPeriod,
  }) = OperationsManagerComputeBudgetEvent;
}
