import 'package:drift/drift.dart';
import 'package:moniplan_core/moniplan_core.dart';

final class PlannerRepoDrift implements IPlannerRepo {
  final AppDb appDb;
  final AppLog _log;

  PlannerRepoDrift({
    required this.appDb,
  }) : _log = AppLog('PlannerRepoDrift');

  static const _plannerMapper = PlannerMapperDrift();
  static const _paymentMapper = PaymentMapperDrift();
  static const _plannerActualInfoMapper = PlannerActualInfoMapper();

  Future<T> _guard<T>(Future<T> Function() action, {String name = ''}) async {
    try {
      final result = action();
      _log.business('Success: $name()');
      return result;
    } on Object catch (error, trace) {
      _log.error('Failed operation: $name()', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<Planner?> getPlannerById(String id, {bool withActualInfo = false}) async {
    return _guard(
      name: 'getPlannerById',
      () async => _composePlanner(
        plannerDao: await _getPlannerById(id),
        paymentsDao: await _getPaymentsByPlannerId(id),
        actualInfo: withActualInfo ? await getPlannerActualInfo(plannerId: id) : null,
      ),
    );
  }

  @override
  Future<List<Planner>> getPlanners({
    bool withPayments = false,
    bool withActualInfo = true,
  }) async {
    return _guard(
      name: 'getPlanners',
      () async {
        final plannersDao = await appDb.db.managers.paymentPlannersDriftTable.get();

        final paymentsForPlanner = <String, List<Payment>>{};
        if (withPayments) {
          final plannersIds = plannersDao.map((e) => e.plannerId).toSet();

          final allPaymentsDao = await appDb.db.managers.paymentsComposedDriftTable
              .filter((f) => f.plannerId.isIn(plannersIds))
              .get();

          final allPayments = allPaymentsDao.map(_paymentMapper.toDomain).toList();

          for (final payment in allPayments) {
            final list = paymentsForPlanner.putIfAbsent(payment.plannerId, () => []);
            list.add(payment);
          }
        }

        final actualInfosForPlanner = <String, PlannerActualInfo?>{};
        if (withActualInfo) {
          for (final plannerDao in plannersDao) {
            final id = plannerDao.plannerId;
            actualInfosForPlanner[id] = await getPlannerActualInfo(plannerId: id);
          }
        }

        final planners = plannersDao.map((e) {
          return _plannerMapper.toDomain(e).copyWith(
                payments: paymentsForPlanner[e.plannerId] ?? [],
                actualInfo: actualInfosForPlanner[e.plannerId],
              );
        }).toList();

        return planners;
      },
    );
  }

  @override
  Future<Planner?> savePlanner(Planner planner) async {
    return _guard(
      name: 'savePlanner',
      () async {
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

        return appDb.db.transaction(() async {
          await appDb.db.managers.paymentPlannersDriftTable.create(
            (o) => plannerDao,
            mode: InsertMode.insertOrReplace,
          );

          return planner;
        });
      },
    );
  }

  @override
  Future<Payment?> getPaymentById({
    required String plannerId,
    required String paymentId,
  }) async {
    return _guard(
      name: 'getPaymentById',
      () async {
        final paymentInPlanner = await appDb.db.managers.paymentsComposedDriftTable
            .filter((f) => f.plannerId(plannerId) & f.paymentId(paymentId))
            .getSingleOrNull();

        if (paymentInPlanner != null) {
          return _paymentMapper.toDomain(paymentInPlanner);
        }
        return null;
      },
    );
  }

  @override
  Future<List<Payment>> getPaymentsByPlannerId({required String plannerId}) async {
    return _guard(
      name: 'getPaymentsByPlannerId',
      () async {
        final paymentInPlanner = await appDb.db.managers.paymentsComposedDriftTable
            .filter((f) => f.plannerId(plannerId))
            .get();

        final payments = paymentInPlanner.map(_paymentMapper.toDomain).toList();
        return payments;
      },
    );
  }

  @override
  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
    bool allowCreate = false,
  }) async {
    return _guard(
      name: 'savePayment',
      () async {
        final selectorPaymentInPlanner = appDb.db.managers.paymentsComposedDriftTable.filter((f) {
          return f.plannerId(plannerId) & f.paymentId(payment.paymentId);
        });

        final selectorPaymentItself = appDb.db.managers.paymentsComposedDriftTable.filter((f) {
          return f.paymentId(payment.paymentId);
        });

        if (!allowCreate) {
          final paymentInPlanner = await selectorPaymentInPlanner.get();

          if (paymentInPlanner.isEmpty) {
            throw Exception(
                'Payment "${payment.paymentId}" is not linked with Planner "$plannerId"');
          }
        }

        final resultPayment = payment.copyWith(plannerId: plannerId);
        final paymentDao = _paymentMapper.toDto(resultPayment);

        return appDb.db.transaction(() async {
          if (await selectorPaymentItself.exists()) {
            await appDb.db.managers.paymentsComposedDriftTable.replace(paymentDao);
          } else {
            await appDb.db.managers.paymentsComposedDriftTable.create((_) => paymentDao);
          }

          return payment;
        });
      },
    );
  }

  @override
  Future<void> deletePlanner(String plannerId) {
    return _guard(
      name: 'deletePlanner',
      () async {
        return appDb.db.transaction(() async {
          await appDb.db.managers.paymentsComposedDriftTable
              .filter((f) => f.plannerId(plannerId))
              .delete();
          await appDb.db.managers.paymentPlannersDriftTable
              .filter((f) => f.plannerId(plannerId))
              .delete();
          await _deleteInfoForPlanner(plannerId: plannerId);
        });
      },
    );
  }

  @override
  Future<void> deletePayment({
    required String plannerId,
    required String paymentId,
  }) async {
    return _guard(
      name: 'deletePayment',
      () async {
        final selector = appDb.db.managers.paymentsComposedDriftTable.filter((f) {
          return f.plannerId(plannerId) & f.paymentId(paymentId);
        });

        final paymentInPlanner = await selector.exists();

        if (!paymentInPlanner) {
          throw Exception('Payment "$paymentId" is not linked with Planner "$plannerId"');
        }
        await selector.delete();
      },
    );
  }

  @override
  Future<Payment?> fixateRepeatedPayment({
    required String plannerId,
    required String paymentId,
  }) async {
    return _guard(
      name: 'fixateRepeatedPayment',
      () async {
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
      },
    );
  }

  @override
  Future<PlannerActualInfo?> getPlannerActualInfo({required String plannerId}) {
    return _guard(
      name: 'getPlannerActualInfo',
      () async {
        final info = await appDb.db.managers.plannerActualInfoDriftTable
            .filter((f) => f.plannerId.equals(plannerId))
            .get();

        return info.isNotEmpty ? _plannerActualInfoMapper.toDomain(info.first) : null;
      },
    );
  }

  @override
  Future<PlannerActualInfo?> updatePlannerActualInfo({
    required String plannerId,
    required PlannerActualInfo plannerActualInfo,
  }) {
    return _guard(
      name: 'updatePlannerActualInfo',
      () async {
        final updatedDao = _plannerActualInfoMapper.toDto(plannerActualInfo);

        final selector = appDb.db.managers.plannerActualInfoDriftTable
            .filter((f) => f.plannerId.equals(plannerId));

        return appDb.db.transaction(() async {
          if (await selector.exists()) {
            await appDb.db.managers.plannerActualInfoDriftTable.replace(updatedDao);
          } else {
            await appDb.db.managers.plannerActualInfoDriftTable.create((_) => updatedDao);
          }

          return plannerActualInfo;
        });
      },
    );
  }

  Future<void> _deleteInfoForPlanner({
    required String plannerId,
  }) {
    return _guard(
      name: '_deleteInfoForPlanner',
      () async {
        final selector = appDb.db.managers.plannerActualInfoDriftTable
            .filter((f) => f.plannerId.equals(plannerId));

        return appDb.db.transaction(() async {
          if (await selector.exists()) {
            await selector.delete();
          }
        });
      },
    );
  }

  Future<PaymentPlannersDriftTableData?> _getPlannerById(String id) =>
      appDb.db.managers.paymentPlannersDriftTable
          .filter((f) => f.plannerId.equals(id))
          .getSingleOrNull();

  Future<List<PaymentsComposedDriftTableData>> _getPaymentsByPlannerId(String id) =>
      appDb.db.managers.paymentsComposedDriftTable.filter((f) => f.plannerId.equals(id)).get();

  Planner? _composePlanner({
    PaymentPlannersDriftTableData? plannerDao,
    List<PaymentsComposedDriftTableData> paymentsDao = const [],
    PlannerActualInfo? actualInfo,
  }) {
    if (plannerDao != null) {
      final plannerDomain = _plannerMapper.toDomain(plannerDao);
      final paymentsDomain = paymentsDao.map(_paymentMapper.toDomain).toList();

      final result = plannerDomain.copyWith(
        payments: paymentsDomain,
        actualInfo: actualInfo,
      );

      return result;
    }

    return null;
  }
}
