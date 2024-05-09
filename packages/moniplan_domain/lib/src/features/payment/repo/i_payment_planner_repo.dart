import 'package:moniplan_domain/moniplan_domain.dart';

abstract interface class IPaymentPlannerRepo {
  Future<List<PaymentPlanner>> getPlanners();

  Future<PaymentPlanner?> getLastPlanner();

  Future<PaymentPlanner?> getPlannerById(String id);

  Future<PaymentPlanner?> persistPlanner(PaymentPlanner planner);
}
