import 'package:moniplan_core/moniplan_core.dart';

class PlannerMapper implements IMapper<PaymentPlanner, PaymentPlannerDaoOB> {
  @override
  PaymentPlanner toDomain(PaymentPlannerDaoOB data) {
    final id = data.plannerId;
    final start = data.dateStart;
    final end = data.dateEnd;

    if (id == null || start == null || end == null) {
      throw Exception('Cannot compose Planner');
    }

    final paymentMapper = PaymentMapper();

    return PaymentPlanner(
      id: id,
      dateStart: start,
      dateEnd: end,
      payments: data.payments.map(paymentMapper.toDomain).toList(),
      initialBudget: data.initialBudget ?? 0.0,
      shouldGenerate: false,
    );
  }

  @override
  PaymentPlannerDaoOB toDto(PaymentPlanner data) {
    final paymentMapper = PaymentMapper();

    final dto = PaymentPlannerDaoOB(
      plannerId: data.id,
      dateStart: data.dateStart,
      dateEnd: data.dateEnd,
      initialBudget: data.initialBudget.toDouble(),
    );
    dto.payments.addAll(data.payments.map(paymentMapper.toDto));
    return dto;
  }
}
