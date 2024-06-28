import 'package:moniplan_domain/moniplan_domain.dart';

abstract interface class IPaymentPlannerRepo {
  /// Получение списка планнеров.
  Future<List<PaymentPlanner>> getPlanners();

  /// Получение планнера по id.
  Future<PaymentPlanner?> getPlannerById(String id);

  /// Сохранение планнера.
  Future<PaymentPlanner?> savePlanner(PaymentPlanner planner);

  /// Установка свойства включен/не включен в учет
  Future<void> setPaymentEnabled({
    required String plannerId,
    required String paymentId,
    required bool isEnabled,
  });

  /// Установка свойства завершен/не завершен платеж
  Future<void> setPaymentDone({
    required String plannerId,
    required String paymentId,
    required bool isDone,
  });

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
