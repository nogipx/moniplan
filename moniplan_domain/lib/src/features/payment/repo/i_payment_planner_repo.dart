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

  /// Удаление планнера.
  Future<void> deletePlanner(String plannerId);

  /// Удаление платежа.
  Future<void> deletePayment({
    required String plannerId,
    required String paymentId,
  });

  /// Получение платежа по id внутри планера
  Future<Payment?> getPaymentById({
    required String plannerId,
    required String paymentId,
  });

  /// Получение всех платедей по id планера
  Future<List<Payment>> getPaymentsByPlannerId({
    required String plannerId,
  });

  /// Сохранение платежа по id внутри планера
  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
    bool allowCreate = false,
  });

  /// Фиксация текущего повторяющегося платежа и перенос генерации на следующий период.
  ///
  /// В системе может быть только один оригинальный повторяющийся платеж.
  /// 1. Метод берет повторяющйися платеж по id.
  /// 2. Копирует его без повторения на дату платежа.
  /// 3. Скопированный платеж остается в системе как отдельный платеж.
  /// 4. Оригинальный платеж сдвигается на один период вперед.
  ///
  /// Возвращает объект зафиксированного платежа.
  Future<Payment?> fixateRepeatedPayment({
    required String plannerId,
    required String paymentId,
  });
}
