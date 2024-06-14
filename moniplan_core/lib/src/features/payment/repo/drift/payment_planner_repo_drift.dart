import 'package:drift/drift.dart';
import 'package:moniplan_core/moniplan_core.dart';

final class PaymentPlannerRepoDrift implements IPaymentPlannerRepo {
  final MoniplanDriftDb db;

  const PaymentPlannerRepoDrift({
    required this.db,
  });

  static const _plannerMapper = PlannerMapperDrift();
  static const _paymentMapper = PaymentMapperDrift();

  @override
  Future<PaymentPlanner?> getLastPlanner() {
    // TODO: implement getLastPlanner
    throw UnimplementedError();
  }

  @override
  Future<PaymentPlanner?> getPlannerById(String id) {
    return db.transaction<PaymentPlanner?>(() async {
      return _composePlanner(
        plannerDao: await _getPlannerById(id),
        paymentsDao: await _getPaymentsByPlannerId(id),
      );
    });
  }

  @override
  Future<List<PaymentPlanner>> getPlanners() {
    return db.transaction(() async {
      final plannersDao = await db.managers.paymentPlannersDriftTable.get();
      final planners = plannersDao.map(_plannerMapper.toDomain).toList();
      return planners;
    });
  }

  @override
  Future<PaymentPlanner?> persistPlanner(PaymentPlanner planner) async {
    final plannerDao = _plannerMapper.toDto(planner);
    final paymentsDao = planner.payments.map(_paymentMapper.toDto).toList();

    return db.transaction(() async {
      await db.managers.paymentPlannersDriftTable.create(
        (o) => plannerDao,
        mode: InsertMode.insertOrReplace,
      );

      final existingPaymentsDao = await db.managers.paymentsComposedDriftTable
          .filter((f) => f.plannerId.equals(planner.id))
          .get();

      final existingPaymentsIds = existingPaymentsDao.map((e) => e.paymentId).toSet();
      final newPaymentsIds = planner.payments.map((e) => e.paymentId).toSet();

      final paymentsMap = <String, PaymentsComposedDriftTableData>{};
      final combinedPayments = [
        ...existingPaymentsDao,
        ...paymentsDao,
      ];
      for (final payment in combinedPayments) {
        paymentsMap[payment.paymentId] = payment;
      }

      final toReplace = existingPaymentsIds.intersection(newPaymentsIds);
      final toCreate = newPaymentsIds.difference(existingPaymentsIds);
      final toDelete = existingPaymentsIds.difference(newPaymentsIds);
      final combinedIds = {
        ...toReplace,
        ...toCreate,
        ...toDelete,
      };

      final toInsertItems = <PaymentsComposedDriftTableData>[];
      final toDeleteItems = <PaymentsComposedDriftTableData>[];
      for (final id in combinedIds) {
        final updatedPayment = paymentsMap[id];
        if (updatedPayment == null) {
          continue;
        }

        if (toReplace.contains(id) || toCreate.contains(id)) {
          toInsertItems.add(updatedPayment);
        } else if (toDelete.contains(id)) {
          toDeleteItems.add(updatedPayment);
        }
      }

      await db.managers.paymentsComposedDriftTable.bulkCreate(
        (o) => toInsertItems,
        mode: InsertMode.insertOrReplace,
      );

      await db.managers.paymentsComposedDriftTable
          .filter((f) => f.paymentId.isIn(toDelete))
          .delete();

      return planner;
    });
  }

  Future<PaymentPlannersDriftTableData?> _getPlannerById(String id) =>
      db.managers.paymentPlannersDriftTable.filter((f) => f.plannerId.equals(id)).getSingleOrNull();

  Future<List<PaymentsComposedDriftTableData>> _getPaymentsByPlannerId(String id) =>
      db.managers.paymentsComposedDriftTable.filter((f) => f.plannerId.equals(id)).get();

  PaymentPlanner? _composePlanner({
    PaymentPlannersDriftTableData? plannerDao,
    List<PaymentsComposedDriftTableData> paymentsDao = const [],
  }) {
    if (plannerDao != null) {
      final plannerDomain = _plannerMapper.toDomain(plannerDao);
      final paymentsDomain = paymentsDao.map(_paymentMapper.toDomain).toList();

      final result = plannerDomain.copyWith(
        payments: paymentsDomain,
      );

      return result;
    }

    return null;
  }

  @override
  Future<Payment?> getPaymentById({
    required String plannerId,
    required String paymentId,
  }) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
  }) {
    // TODO: implement save
    throw UnimplementedError();
  }

  @override
  Future<void> setPaymentDone({
    required String plannerId,
    required String paymentId,
    required bool isDone,
  }) {
    // TODO: implement setDoneState
    throw UnimplementedError();
  }

  @override
  Future<void> setPaymentEnabled({
    required String plannerId,
    required String paymentId,
    required bool isEnabled,
  }) {
    // TODO: implement setEnabledState
    throw UnimplementedError();
  }
}
