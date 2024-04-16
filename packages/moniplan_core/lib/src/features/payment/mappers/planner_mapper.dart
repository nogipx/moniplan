import 'package:moniplan_core/moniplan_core.dart';

class PlannerMapper implements IMapper<PaymentPlanner, PaymentPlannerDaoIsar> {
  @override
  PaymentPlanner toDomain(PaymentPlannerDaoIsar data) {
    final id = data.id;
    final start = data.dateStart;
    final end = data.dateEnd;

    if (id == null || start == null || end == null) {
      throw Exception('Cannot compose Planner');
    }

    final paymentMapper = PaymentMapper();
    final payments = data.payments..loadSync();

    return PaymentPlanner(
      id: id,
      dateStart: start,
      dateEnd: end,
      payments: payments.map(paymentMapper.toDomain).toList(),
      initialBudget: data.initialBudget ?? 0.0,
      shouldGenerate: false,
    );
  }

  @override
  PaymentPlannerDaoIsar toDto(PaymentPlanner data) {
    final paymentMapper = PaymentMapper();

    final dto = PaymentPlannerDaoIsar(
      id: data.id,
      dateStart: data.dateStart,
      dateEnd: data.dateEnd,
      initialBudget: data.initialBudget.toDouble(),
    );
    dto.payments.addAll(data.payments.map(paymentMapper.toDto));
    return dto;
  }
}
