import 'package:moniplan_core/moniplan_core.dart';

class PlannerMapperDrift implements IMapper<PaymentPlanner, PaymentPlannersDriftTableData> {
  const PlannerMapperDrift();

  @override
  PaymentPlanner toDomain(PaymentPlannersDriftTableData data) {
    final paymentId = data.plannerId;
    final start = data.dateStart;
    final end = data.dateEnd;

    if (start == null || end == null) {
      throw Exception('Cannot compose Planner');
    }

    return PaymentPlanner(
      id: paymentId,
      dateStart: start,
      dateEnd: end,
      initialBudget: data.initialBudget,
      isDraft: data.isDraft,
    );
  }

  @override
  PaymentPlannersDriftTableData toDto(PaymentPlanner data) {
    final dto = PaymentPlannersDriftTableData(
      plannerId: data.id,
      dateStart: data.dateStart,
      dateEnd: data.dateEnd,
      initialBudget: data.initialBudget.toDouble(),
      isDraft: data.isDraft,
    );
    return dto;
  }
}
