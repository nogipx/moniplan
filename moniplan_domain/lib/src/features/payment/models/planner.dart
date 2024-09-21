import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _Planner;

  factory Planner.fromJson(Map<String, dynamic> json) => _$PlannerFromJson(json);

  num get needToPay {
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
