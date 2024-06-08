import 'package:moniplan_domain/moniplan_domain.dart';

abstract interface class IPaymentPlannerRepo {
  Future<List<PaymentPlanner>> getPlanners();

  Future<PaymentPlanner?> getLastPlanner();

  Future<PaymentPlanner?> getPlannerById(String id);

  Future<PaymentPlanner?> persistPlanner(PaymentPlanner planner);

  Future<void> setPaymentEnabled({
    required String plannerId,
    required String paymentId,
    required bool isEnabled,
  });

  Future<void> setPaymentDone({
    required String plannerId,
    required String paymentId,
    required bool isDone,
  });

  Future<Payment?> getPaymentById({
    required String plannerId,
    required String paymentId,
  });

  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
  });
}
