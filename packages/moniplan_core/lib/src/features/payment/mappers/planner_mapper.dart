import 'package:moniplan_core/moniplan_core.dart';

class PlannerMapperOB implements IMapper<PaymentPlanner, PaymentPlannerDaoOB> {
  const PlannerMapperOB();

  @override
  PaymentPlanner toDomain(PaymentPlannerDaoOB data) {
    final paymentId = data.plannerId;
    final start = data.dateStart;
    final end = data.dateEnd;

    if (paymentId == null || start == null || end == null) {
      throw Exception('Cannot compose Planner');
    }

    final paymentMapper = PaymentMapperOB();

    return PaymentPlanner(
      intId: data.id,
      id: paymentId,
      dateStart: start,
      dateEnd: end,
      payments: data.payments.map(paymentMapper.toDomain).toList(),
      initialBudget: data.initialBudget ?? 0.0,
      isDraft: data.isDraft ?? true,
    );
  }

  @override
  PaymentPlannerDaoOB toDto(PaymentPlanner data) {
    final paymentMapper = PaymentMapperOB();

    final dto = PaymentPlannerDaoOB(
      id: data.intId,
      plannerId: data.id,
      dateStart: data.dateStart,
      dateEnd: data.dateEnd,
      initialBudget: data.initialBudget.toDouble(),
      isDraft: data.isDraft,
    );
    dto.payments.addAll(data.payments.map(paymentMapper.toDto));
    return dto;
  }
}
