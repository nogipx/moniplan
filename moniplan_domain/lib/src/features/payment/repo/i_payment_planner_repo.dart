import 'package:moniplan_domain/moniplan_domain.dart';

abstract interface class IPlannerRepo {
  /// Получение списка планнеров.
  Future<List<PaymentPlanner>> getPlanners({
    bool withPayments = false,
  });

  /// Получение планнера по id.
  Future<PaymentPlanner?> getPlannerById(String id);

  /// Сохранение планнера.
  Future<PaymentPlanner?> savePlanner(PaymentPlanner planner);

  /// Получение платежа по id внутри планера
  Future<Payment?> getPaymentById({
    required String plannerId,
    required String paymentId,
  });

  /// Сохранение платежа по id внутри планера
  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
  });
}
