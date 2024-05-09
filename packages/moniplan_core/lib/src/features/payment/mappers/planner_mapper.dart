import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/features/payment/dao/drift/_drift_database.dart';

class PlannerMapperOB implements IMapper<PaymentPlanner, PaymentPlannersDriftTableData> {
  const PlannerMapperOB();

  @override
  PaymentPlanner toDomain(PaymentPlannersDriftTableData data) {
    final paymentId = data.plannerId;
    final start = data.dateStart;
    final end = data.dateEnd;

    if (paymentId == null || start == null || end == null) {
      throw Exception('Cannot compose Planner');
    }

    final paymentMapper = PaymentMapperOB();

    return PaymentPlanner(
      id: paymentId,
      dateStart: start,
      dateEnd: end,
      // payments: data.payments.map(paymentMapper.toDomain).toList(),
      initialBudget: data.initialBudget ?? 0.0,
      isDraft: data.isDraft ?? true,
    );
  }

  @override
  PaymentPlannersDriftTableData toDto(PaymentPlanner data) {
    final paymentMapper = PaymentMapperOB();

    final dto = PaymentPlannersDriftTableData(
      id: 0,
      plannerId: data.id,
      dateStart: data.dateStart,
      dateEnd: data.dateEnd,
      initialBudget: data.initialBudget.toDouble(),
      isDraft: data.isDraft,
    );
    // dto.payments.addAll(data.payments.map(paymentMapper.toDto));
    return dto;
  }
}
