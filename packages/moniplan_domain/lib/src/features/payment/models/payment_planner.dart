import 'package:freezed_annotation/freezed_annotation.dart';

import '_index.dart';

part 'payment_planner.freezed.dart';
part 'payment_planner.g.dart';

@Freezed()
class PaymentPlanner with _$PaymentPlanner {
  const PaymentPlanner._();

  const factory PaymentPlanner({
    required final String id,
    required final DateTime dateStart,
    required final DateTime dateEnd,
    @Default([]) final List<Payment> payments,
    @Default(0) final num initialBudget,
    @Default(false) final bool shouldGenerate,
  }) = _PaymentPlanner;

  factory PaymentPlanner.fromJson(Map<String, dynamic> json) => _$PaymentPlannerFromJson(json);
}
