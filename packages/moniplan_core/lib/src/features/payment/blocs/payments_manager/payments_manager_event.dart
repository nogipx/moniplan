import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'payments_manager_event.freezed.dart';
part 'payments_manager_event.g.dart';

@freezed
class PaymentsManagerEvent with _$PaymentsManagerEvent {
  const PaymentsManagerEvent._();

  @JsonSerializable()
  const factory PaymentsManagerEvent.computeBudget({
    @Default(IListConst([])) Iterable<Payment> payments,
    double? initialBudget,
    required DateTime startPeriod,
    required DateTime endPeriod,
  }) = PaymentsManagerComputeBudgetEvent;

  factory PaymentsManagerEvent.fromJson(Map<String, dynamic> json) =>
      _$PaymentsManagerEventFromJson(json);
}
