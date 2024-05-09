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
    @Default(false) final bool isDraft,
  }) = _PaymentPlanner;

  factory PaymentPlanner.fromJson(Map<String, dynamic> json) => _$PaymentPlannerFromJson(json);

  num get needToPay {
    if (isDraft == true) {
      return -1;
    }

    final futurePayments = payments
        .where((e) => e.details.type == PaymentType.expense && !e.isDone)
        .map((e) => e.details.money.abs())
        .fold(0.0, (acc, e) => acc + e);

    return futurePayments;
  }

  int get countDonePayments => payments.where((e) => e.isDone).length;
  int get countWaitingPayments => payments.where((e) => !e.isDone).length;
  int get countDisabledPayments => payments.where((e) => !e.isEnabled).length;
}
