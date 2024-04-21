import 'package:moniplan_core/moniplan_core.dart';

@Entity()
class PaymentPlannerDaoOB {
  @Id()
  int id;

  @Unique()
  @Index()
  String? plannerId;

  DateTime? dateStart;
  DateTime? dateEnd;

  double? initialBudget;
  bool? isDraft;

  @Backlink('planner')
  final payments = ToMany<PaymentComposedDaoOB>();

  PaymentPlannerDaoOB({
    this.id = 0,
    this.plannerId,
    this.dateStart,
    this.dateEnd,
    this.initialBudget,
    this.isDraft,
  });
}
