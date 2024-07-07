// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

part 'planner_event.freezed.dart';

@freezed
class PlannerEvent with _$PlannerEvent {
  const PlannerEvent._();

  const factory PlannerEvent.computeBudget() = PlannerComputeBudgetEvent;

  const factory PlannerEvent.updatePayment({
    required final Payment newPayment,
    @Default(false) bool create,
  }) = PlannerUpdatePaymentEvent;

  const factory PlannerEvent.deletePayment({
    required final String paymentId,
  }) = PlannerDeletePaymentEvent;
}
