// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'payments_manager_event.freezed.dart';
part 'payments_manager_event.g.dart';

@freezed
class PaymentsManagerEvent with _$PaymentsManagerEvent {
  const PaymentsManagerEvent._();

  const factory PaymentsManagerEvent.computeBudget({
    required final String plannerId,
  }) = PaymentsManagerComputeBudgetEvent;

  @JsonSerializable()
  const factory PaymentsManagerEvent.reload() = PaymentsManagerReloadEvent;
}
