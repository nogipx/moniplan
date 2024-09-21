import 'package:drift/drift.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_domain/src/features/payment/models/planner_actual_info.dart';

final class PlannerRepoDrift implements IPlannerRepo {
  final MoniplanDriftDb db;

  const PlannerRepoDrift({
    required this.db,
  });

  static const _plannerMapper = PlannerMapperDrift();
  static const _paymentMapper = PaymentMapperDrift();

  @override
  Future<Planner?> getPlannerById(String id) {
    return db.transaction<Planner?>(() async {
      return _composePlanner(
        plannerDao: await _getPlannerById(id),
        paymentsDao: await _getPaymentsByPlannerId(id),
      );
    });
  }

  @override
  Future<List<Planner>> getPlanners({
    bool withPayments = false,
  }) {
    return db.transaction(() async {
      final plannersDao = await db.managers.paymentPlannersDriftTable.get();

      final paymentsForPlanner = <String, List<Payment>>{};

      if (withPayments) {
        final plannersIds = plannersDao.map((e) => e.plannerId).toSet();

        final allPaymentsDao = await db.managers.paymentsComposedDriftTable
            .filter((f) => f.plannerId.isIn(plannersIds))
            .get();

        final allPayments = allPaymentsDao.map(_paymentMapper.toDomain).toList();

        for (final payment in allPayments) {
          final list = paymentsForPlanner.putIfAbsent(payment.plannerId, () => []);
          list.add(payment);
        }
      }

      final planners = plannersDao.map((e) {
        return _plannerMapper.toDomain(e).copyWith(
              payments: paymentsForPlanner[e.plannerId] ?? [],
            );
      }).toList();

      return planners;
    });
  }

  @override
  Future<Planner?> savePlanner(Planner planner) async {
    if (!planner.isGenerationAllowed) {
      throw Exception(
        'Cannot persist generated planners. '
        'Only blueprints allowed to persist.',
      );
    }
    if (planner.id.isEmpty) {
      throw Exception(
        'Invalid planner.'
        'Planner should have id.',
      );
    }

    final plannerDao = _plannerMapper.toDto(planner);
    final paymentsDao = planner.payments
        .map((e) => e.copyWith(plannerId: planner.id))
        .map(_paymentMapper.toDto)
        .toList();

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

  Planner? _composePlanner({
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
    return db.transaction(() async {
      final paymentInPlanner = await db.managers.paymentsComposedDriftTable
          .filter((f) => f.plannerId(plannerId) & f.paymentId(paymentId))
          .getSingleOrNull();

      if (paymentInPlanner != null) {
        return _paymentMapper.toDomain(paymentInPlanner);
      }
      return null;
    });
  }

  @override
  Future<List<Payment>> getPaymentsByPlannerId({required String plannerId}) {
    return db.transaction(() async {
      final paymentInPlanner =
          await db.managers.paymentsComposedDriftTable.filter((f) => f.plannerId(plannerId)).get();

      final payments = paymentInPlanner.map(_paymentMapper.toDomain).toList();
      return payments;
    });
  }

  @override
  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
    bool allowCreate = false,
  }) async {
    return db.transaction(() async {
      final selectorPaymentInPlanner = db.managers.paymentsComposedDriftTable.filter((f) {
        return f.plannerId(plannerId) & f.paymentId(payment.paymentId);
      });

      final selectorPaymentItself = db.managers.paymentsComposedDriftTable.filter((f) {
        return f.paymentId(payment.paymentId);
      });

      if (!allowCreate) {
        final paymentInPlanner = await selectorPaymentInPlanner.get();

        if (paymentInPlanner.isEmpty) {
          throw Exception('Payment "${payment.paymentId}" is not linked with Planner "$plannerId"');
        }
      }

      final resultPayment = payment.copyWith(plannerId: plannerId);
      final paymentDao = _paymentMapper.toDto(resultPayment);

      try {
        if (await selectorPaymentItself.exists()) {
          await db.managers.paymentsComposedDriftTable.replace(paymentDao);
        } else {
          await db.managers.paymentsComposedDriftTable.create((_) => paymentDao);
        }
        return payment;
      } on Object catch (_) {
        return null;
      }
    });
  }

  @override
  Future<void> deletePlanner(String plannerId) {
    return db.transaction(() async {
      await db.managers.paymentsComposedDriftTable.filter((f) => f.plannerId(plannerId)).delete();
      await db.managers.paymentPlannersDriftTable.filter((f) => f.plannerId(plannerId)).delete();

      /// TODO(при удалении планнера также удалять поледние результаты)
    });
  }

  @override
  Future<void> deletePayment({
    required String plannerId,
    required String paymentId,
  }) async {
    return db.transaction(() async {
      final selector = db.managers.paymentsComposedDriftTable.filter((f) {
        return f.plannerId(plannerId) & f.paymentId(paymentId);
      });

      final paymentInPlanner = await selector.exists();

      if (!paymentInPlanner) {
        throw Exception('Payment "$paymentId" is not linked with Planner "$plannerId"');
      }

      await selector.delete();
    });
  }

  @override
  Future<Payment?> fixateRepeatedPayment({
    required String plannerId,
    required String paymentId,
  }) {
    return db.transaction(() async {
      final payment = await getPaymentById(plannerId: plannerId, paymentId: paymentId);
      if (payment == null) {
        throw Exception('Cannot find payment with id "$paymentId" in planner "$plannerId"');
      }

      if (!payment.isRepeatParent) {
        throw Exception('Payment should be repeated and parent');
      }

      final copiedPayment = payment.copyWith(
        paymentId: const Uuid().v4(),
        repeat: DateTimeRepeat.noRepeat,
        dateStart: null,
        dateEnd: null,
      );

      final updatedOriginalPayment = payment.copyWith(
        date: payment.repeat.next(payment.date),
      );

      await savePayment(
        plannerId: plannerId,
        payment: copiedPayment,
        allowCreate: true,
      );

      await savePayment(
        plannerId: plannerId,
        payment: updatedOriginalPayment,
      );

      return copiedPayment;
    });
  }

  @override
  Future<PlannerActualInfo?> getPlannerActualInfo({required String plannerId}) {
    // TODO: implement getPlannerActualInfo
    throw UnimplementedError();
  }

  @override
  Future<PlannerActualInfo?> updatePlannerActualInfo({
    required String plannerId,
    required PlannerActualInfo plannerActualInfo,
  }) {
    // TODO: implement updatePlannerActualInfo
    throw UnimplementedError();
  }
}
