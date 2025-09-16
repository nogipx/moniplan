import 'package:drift/drift.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/features/payment/dao/payments_composed_drift_table.dart';

part 'payment_dao.g.dart';

@DriftAccessor(tables: [PaymentsComposedDriftTable])
class PaymentDao extends DatabaseAccessor<MoniplanDriftDb> with _$PaymentDaoMixin {
  PaymentDao(super.db);

  /// Получение платежа по ID
  Future<PaymentsComposedDriftTableData?> getPaymentById(String paymentId) {
    return (select(paymentsComposedDriftTable)
      ..where((tbl) => tbl.paymentId.equals(paymentId))).getSingleOrNull();
  }

  /// Получение платежа по ID в рамках планировщика
  Future<PaymentsComposedDriftTableData?> getPaymentByIdInPlanner(
    String paymentId,
    String plannerId,
  ) {
    return (select(paymentsComposedDriftTable)..where(
      (tbl) => tbl.paymentId.equals(paymentId) & tbl.plannerId.equals(plannerId),
    )).getSingleOrNull();
  }

  /// Получение всех платежей планировщика
  Future<List<PaymentsComposedDriftTableData>> getPaymentsByPlannerId(String plannerId) {
    return (select(paymentsComposedDriftTable)
      ..where((tbl) => tbl.plannerId.equals(plannerId))).get();
  }

  /// Проверка существования платежа
  Future<bool> paymentExists(String paymentId) async {
    final result =
        await (select(paymentsComposedDriftTable)
          ..where((tbl) => tbl.paymentId.equals(paymentId))).get();
    return result.isNotEmpty;
  }

  /// Проверка существования платежа в планировщике
  Future<bool> paymentExistsInPlanner(String paymentId, String plannerId) async {
    final result =
        await (select(
          paymentsComposedDriftTable,
        )..where((tbl) => tbl.paymentId.equals(paymentId) & tbl.plannerId.equals(plannerId))).get();
    return result.isNotEmpty;
  }

  /// Сохранение платежа (создание или обновление)
  Future<void> savePayment(PaymentsComposedDriftTableData payment) async {
    await into(paymentsComposedDriftTable).insertOnConflictUpdate(payment);
  }

  /// Создание платежа
  Future<void> createPayment(PaymentsComposedDriftTableData payment) async {
    await into(paymentsComposedDriftTable).insert(payment);
  }

  /// Обновление платежа
  Future<void> updatePayment(PaymentsComposedDriftTableData payment) async {
    await update(paymentsComposedDriftTable).replace(payment);
  }

  /// Удаление платежа
  Future<void> deletePayment(String paymentId) async {
    await (delete(paymentsComposedDriftTable)
      ..where((tbl) => tbl.paymentId.equals(paymentId))).go();
  }

  /// Удаление платежа из планировщика
  Future<void> deletePaymentFromPlanner(String paymentId, String plannerId) async {
    await (delete(paymentsComposedDriftTable)
      ..where((tbl) => tbl.paymentId.equals(paymentId) & tbl.plannerId.equals(plannerId))).go();
  }

  /// Удаление всех платежей планировщика
  Future<void> deleteAllPaymentsFromPlanner(String plannerId) async {
    await (delete(paymentsComposedDriftTable)
      ..where((tbl) => tbl.plannerId.equals(plannerId))).go();
  }
}
