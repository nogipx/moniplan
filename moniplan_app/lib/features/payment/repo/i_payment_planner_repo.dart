import 'package:moniplan_app/core/_index.dart';

abstract interface class IPlannerRepo {
  /// Получение списка планнеров.
  Future<List<Planner>> getPlanners({bool withPayments = false, bool withActualInfo = true});

  /// Id текущего планнера если выбран.
  Future<String?> getCurrentPlannerId();

  /// Получение текущего планнера если он выбран.
  Future<Planner?> getCurrentPlanner({bool withActualInfo = false});

  /// Получение планнера по id.
  /// Можно запросить вместе с актуальной ифнормацией.
  Future<Planner?> getPlannerById(String id, {bool withActualInfo = false});

  /// Назначение планнера текущим.
  Future<void> setCurrentPlanner(String plannerId);

  /// Очистить флаг текущего планнера.
  Future<void> clearCurrentPlanner();

  /// Сохранение планнера.
  Future<Planner?> savePlanner(Planner planner);

  /// Удаление планнера.
  Future<void> deletePlanner(String plannerId);

  /// Создание копии планнера
  Future<Planner?> duplicatePlanner({
    required String originalPlannerId,
    required DateTime newStartDate,
    required DateTime newEndDate,
    String? newName,
  });

  /// Обновление результатов просчета планнера.
  Future<PlannerActualInfo?> updatePlannerActualInfo({
    required String plannerId,
    required PlannerActualInfo plannerActualInfo,
  });

  /// Получение последних результатов просчета планнера.
  Future<PlannerActualInfo?> getPlannerActualInfo({required String plannerId});

  /// Удаление платежа.
  Future<void> deletePayment({required String plannerId, required String paymentId});

  /// Получение платежа по id внутри планера
  Future<Payment?> getPaymentById({required String plannerId, required String paymentId});

  /// Получение всех платедей по id планера
  Future<List<Payment>> getPaymentsByPlannerId({required String plannerId});

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
  Future<Payment?> fixateRepeatedPayment({required String plannerId, required String paymentId});
}
