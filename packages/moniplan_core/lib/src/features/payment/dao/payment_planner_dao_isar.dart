import 'package:moniplan_core/moniplan_core.dart';

part 'payment_planner_dao_isar.g.dart';

@Collection()
class PaymentPlannerDaoIsar {
  String id;
  Id get isarId => fastHash(id!);

  DateTime? dateStart;
  DateTime? dateEnd;

  double? initialBudget;

  @Backlink(to: 'planner')
  final payments = IsarLinks<PaymentComposedDaoIsar>();

  PaymentPlannerDaoIsar({
    required this.id,
    this.dateStart,
    this.dateEnd,
    this.initialBudget,
  });
}
