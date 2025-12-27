import 'dart:async';

import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';
import 'package:uuid/uuid.dart';

import 'i_payment_planner_repo.dart';

class PlannerRepoDataService implements IPlannerRepo {
  PlannerRepoDataService({required this.appDb}) : _log = RpcLogger('PlannerRepoDataService');

  final AppDb appDb;
  final RpcLogger _log;

  static const _plannersCollection = 'planners';
  static const _paymentsCollection = 'payments';
  static const _actualInfoCollection = 'planner_actual_info';

  DataServiceClient get _dataService => appDb.dataService;

  Future<T> _guard<T>(String name, Future<T> Function() action) async {
    try {
      return await action();
    } on Object catch (error, trace) {
      _log.error('Failed operation: $name', error: error, stackTrace: trace);
      rethrow;
    }
  }

  Planner _mapPlanner(DataRecord record) {
    final payload = Map<String, dynamic>.from(record.payload);
    payload['id'] = record.id;
    return Planner.fromJson(payload);
  }

  Payment _mapPayment(DataRecord record) {
    final payload = Map<String, dynamic>.from(record.payload);
    payload['paymentId'] = record.id;
    return Payment.fromJson(payload);
  }

  PlannerActualInfo _mapActualInfo(DataRecord record) {
    final payload = Map<String, dynamic>.from(record.payload);
    payload['plannerId'] = record.id;
    return PlannerActualInfo.fromJson(payload);
  }

  Map<String, dynamic> _plannerPayload(Planner planner) {
    final base = planner.copyWith(payments: [], actualInfo: null);
    return base.toJson();
  }

  Map<String, dynamic> _paymentPayload(Payment payment) {
    return payment.toJson();
  }

  Map<String, dynamic> _actualInfoPayload(PlannerActualInfo info) {
    return info.toJson();
  }

  @override
  Future<Planner?> getPlannerById(String id, {bool withActualInfo = false}) {
    return _guard('getPlannerById', () async {
      final record = await _dataService.get(collection: _plannersCollection, id: id);
      if (record == null) {
        return null;
      }

      final planner = _mapPlanner(record);
      final payments = await getPaymentsByPlannerId(plannerId: id);
      final actualInfo = withActualInfo ? await getPlannerActualInfo(plannerId: id) : null;

      return planner.copyWith(payments: payments, actualInfo: actualInfo);
    });
  }

  @override
  Future<List<Planner>> getPlanners({bool withPayments = false, bool withActualInfo = true}) {
    return _guard('getPlanners', () async {
      final response = await _dataService.list(
        collection: _plannersCollection,
        options: const QueryOptions(limit: 1000),
      );
      final planners = response.records.map(_mapPlanner).toList(growable: false);

      if (!withPayments && !withActualInfo) {
        return planners;
      }

      final result = <Planner>[];
      for (final planner in planners) {
        final payments = withPayments
            ? await getPaymentsByPlannerId(plannerId: planner.id)
            : const <Payment>[];
        final actualInfo = withActualInfo ? await getPlannerActualInfo(plannerId: planner.id) : null;
        result.add(planner.copyWith(payments: payments, actualInfo: actualInfo));
      }
      return result;
    });
  }

  @override
  Future<Planner?> savePlanner(Planner planner) {
    return _guard('savePlanner', () async {
      if (!planner.isGenerationAllowed) {
        throw Exception('Cannot persist generated planners. Only blueprints allowed to persist.');
      }
      if (planner.id.isEmpty) {
        throw Exception('Invalid planner. Planner should have id.');
      }

      final payload = _plannerPayload(planner);
      final existing = await _dataService.get(collection: _plannersCollection, id: planner.id);

      if (existing == null) {
        await _dataService.create(
          collection: _plannersCollection,
          id: planner.id,
          payload: payload,
        );
      } else {
        await _dataService.update(
          collection: _plannersCollection,
          id: planner.id,
          expectedVersion: existing.version,
          payload: payload,
        );
      }

      return planner;
    });
  }

  @override
  Future<Payment?> getPaymentById({required String plannerId, required String paymentId}) {
    return _guard('getPaymentById', () async {
      final record = await _dataService.get(collection: _paymentsCollection, id: paymentId);
      if (record == null) {
        return null;
      }
      final payment = _mapPayment(record);
      return payment.plannerId == plannerId ? payment : null;
    });
  }

  @override
  Future<List<Payment>> getPaymentsByPlannerId({required String plannerId}) {
    return _guard('getPaymentsByPlannerId', () async {
      final response = await _dataService.list(
        collection: _paymentsCollection,
        filter: RecordFilter(equals: {'plannerId': plannerId}),
        options: const QueryOptions(limit: 5000),
      );
      return response.records.map(_mapPayment).toList(growable: false);
    });
  }

  @override
  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
    bool allowCreate = false,
  }) {
    return _guard('savePayment', () async {
      final target = payment.copyWith(plannerId: plannerId, dateStart: null);
      final payload = _paymentPayload(target);
      final existing = await _dataService.get(collection: _paymentsCollection, id: target.paymentId);

      if (existing == null && !allowCreate) {
        throw Exception('Payment "${payment.paymentId}" is not linked with Planner "$plannerId"');
      }

      if (existing == null) {
        await _dataService.create(
          collection: _paymentsCollection,
          id: target.paymentId,
          payload: payload,
        );
      } else {
        await _dataService.update(
          collection: _paymentsCollection,
          id: target.paymentId,
          expectedVersion: existing.version,
          payload: payload,
        );
      }

      return target;
    });
  }

  @override
  Future<void> deletePlanner(String plannerId) {
    return _guard('deletePlanner', () async {
      final payments = await getPaymentsByPlannerId(plannerId: plannerId);
      if (payments.isNotEmpty) {
        await _dataService.bulkDelete(
          collection: _paymentsCollection,
          ids: payments.map((p) => p.paymentId).toList(),
        );
      }
      await _dataService.delete(collection: _plannersCollection, id: plannerId);
      await _dataService.delete(
        collection: _actualInfoCollection,
        id: plannerId,
      );
    });
  }

  @override
  Future<Planner?> duplicatePlanner({
    required String originalPlannerId,
    required DateTime newStartDate,
    required DateTime newEndDate,
    String? newName,
  }) {
    return _guard('duplicatePlanner', () async {
      final original = await getPlannerById(originalPlannerId, withActualInfo: false);
      if (original == null) {
        throw Exception('Original planner with id "$originalPlannerId" not found');
      }

      final originalPayments = await getPaymentsByPlannerId(plannerId: originalPlannerId);
      final newPlannerId = const Uuid().v4();
      final plannerName = newName ?? '${original.name} (копия)';

      final duplicatedPlanner = original.copyWith(
        id: newPlannerId,
        name: plannerName,
        dateStart: newStartDate,
        dateEnd: newEndDate,
        payments: [],
        actualInfo: null,
        isGenerationAllowed: true,
      );

      await savePlanner(duplicatedPlanner);

      for (final payment in originalPayments) {
        final duplicatedPayment = payment.copyWith(
          paymentId: const Uuid().v4(),
          plannerId: newPlannerId,
        );
        await savePayment(
          plannerId: newPlannerId,
          payment: duplicatedPayment,
          allowCreate: true,
        );
      }

      return duplicatedPlanner;
    });
  }

  @override
  Future<void> deletePayment({required String plannerId, required String paymentId}) {
    return _guard('deletePayment', () async {
      final payment = await getPaymentById(plannerId: plannerId, paymentId: paymentId);
      if (payment == null) {
        throw Exception('Payment "$paymentId" is not linked with Planner "$plannerId"');
      }
      await _dataService.delete(collection: _paymentsCollection, id: paymentId);
    });
  }

  @override
  Future<Payment?> fixateRepeatedPayment({
    required String plannerId,
    required String paymentId,
  }) {
    return _guard('fixateRepeatedPayment', () async {
      final payment = await getPaymentById(plannerId: plannerId, paymentId: paymentId);
      if (payment == null) {
        throw Exception('Cannot find payment with id "$paymentId" in planner "$plannerId"');
      }
      if (!payment.isRepeatParent) {
        throw Exception('Payment should be repeated and parent');
      }

      final record = await _dataService.get(collection: _paymentsCollection, id: paymentId);
      if (record == null) {
        throw Exception('Payment record is missing');
      }

      final copiedPayment = payment.copyWith(
        paymentId: const Uuid().v4(),
        repeat: DateTimeRepeat.noRepeat,
        dateStart: null,
        dateEnd: null,
      );
      final updatedOriginalPayment = payment.copyWith(date: payment.repeat.next(payment.date));

      await _dataService.create(
        collection: _paymentsCollection,
        id: copiedPayment.paymentId,
        payload: _paymentPayload(copiedPayment.copyWith(plannerId: plannerId)),
      );

      await _dataService.update(
        collection: _paymentsCollection,
        id: payment.paymentId,
        expectedVersion: record.version,
        payload: _paymentPayload(updatedOriginalPayment),
      );

      return copiedPayment.copyWith(plannerId: plannerId);
    });
  }

  @override
  Future<PlannerActualInfo?> getPlannerActualInfo({required String plannerId}) {
    return _guard('getPlannerActualInfo', () async {
      final record =
          await _dataService.get(collection: _actualInfoCollection, id: plannerId);
      return record == null ? null : _mapActualInfo(record);
    });
  }

  @override
  Future<PlannerActualInfo?> updatePlannerActualInfo({
    required String plannerId,
    required PlannerActualInfo plannerActualInfo,
  }) {
    return _guard('updatePlannerActualInfo', () async {
      final payload = _actualInfoPayload(plannerActualInfo.copyWith(plannerId: plannerId));
      final existing =
          await _dataService.get(collection: _actualInfoCollection, id: plannerId);

      if (existing == null) {
        await _dataService.create(
          collection: _actualInfoCollection,
          id: plannerId,
          payload: payload,
        );
      } else {
        await _dataService.update(
          collection: _actualInfoCollection,
          id: plannerId,
          expectedVersion: existing.version,
          payload: payload,
        );
      }

      return plannerActualInfo;
    });
  }
}
