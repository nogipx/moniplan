import 'dart:async';

import 'package:collection/collection.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/database/collections.dart';
import 'package:moniplan_app/features/payment/repo/i_payment_planner_repo.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';
import 'package:uuid/uuid.dart';

class PlannerRepoDataService implements IPlannerRepo {
  PlannerRepoDataService({required this.appDb}) : _log = RpcLogger('PlannerRepoDataService');

  final AppDb appDb;
  final RpcLogger _log;

  static const _uuid = Uuid();
  static const _pageSize = 200;

  DataService get _service => appDb.service;

  Future<T> _guard<T>(Future<T> Function() action, {String name = ''}) async {
    try {
      return await action();
    } on RpcDataError catch (error, stackTrace) {
      await _log.error('Data operation failed: $name', error: error, stackTrace: stackTrace);
      rethrow;
    } on Object catch (error, stackTrace) {
      await _log.error('Unexpected error in $name', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Planner>> getPlanners({bool withPayments = false, bool withActualInfo = true}) {
    return _guard(name: 'getPlanners', () async {
      final plannerRecords = await _listAllRecords(plannersCollection);
      final planners = <String, Planner>{};
      for (final record in plannerRecords) {
        planners[record.id] = _decodePlanner(record);
      }

      Map<String, List<Payment>> paymentsByPlanner = const {};
      if (withPayments) {
        final paymentRecords = await _listAllRecords(paymentsCollection);
        paymentsByPlanner = groupBy(
          paymentRecords.map(_decodePayment),
          (payment) => payment.plannerId,
        );
      }

      Map<String, PlannerActualInfo> actualInfoByPlanner = const {};
      if (withActualInfo) {
        final infoRecords = await _listAllRecords(plannerInfoCollection);
        actualInfoByPlanner = {
          for (final record in infoRecords) record.id: _decodePlannerActualInfo(record),
        };
      }

      return planners.values
          .map(
            (planner) => planner.copyWith(
              payments: withPayments ? paymentsByPlanner[planner.id] ?? const [] : const [],
              actualInfo: withActualInfo ? actualInfoByPlanner[planner.id] : null,
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<Planner?> getPlannerById(String id, {bool withActualInfo = false}) {
    return _guard(name: 'getPlannerById', () async {
      final record = await _service.get(collection: plannersCollection, id: id);
      if (record == null) {
        return null;
      }

      final planner = _decodePlanner(record);
      final payments = await getPaymentsByPlannerId(plannerId: id);
      final info = withActualInfo ? await getPlannerActualInfo(plannerId: id) : null;
      return planner.copyWith(payments: payments, actualInfo: info);
    });
  }

  @override
  Future<Planner?> savePlanner(Planner planner) {
    return _guard(name: 'savePlanner', () async {
      if (!planner.isGenerationAllowed) {
        throw Exception('Cannot persist generated planners. Only blueprints allowed to persist.');
      }
      if (planner.id.isEmpty) {
        throw Exception('Planner should have id.');
      }

      final payload = _encodePlanner(planner);
      final existing = await _service.get(collection: plannersCollection, id: planner.id);
      DataRecord record;
      if (existing == null) {
        record = await _service.create(
          collection: plannersCollection,
          id: planner.id,
          payload: payload,
        );
      } else {
        record = await _service.update(
          collection: plannersCollection,
          id: planner.id,
          expectedVersion: existing.version,
          payload: payload,
        );
      }

      await appDb.touchLastActionDate();
      return _decodePlanner(record);
    });
  }

  @override
  Future<void> deletePlanner(String plannerId) {
    return _guard(name: 'deletePlanner', () async {
      final paymentRecords = await _listAllRecords(
        paymentsCollection,
        filter: RecordFilter(equals: {'plannerId': plannerId}),
      );
      if (paymentRecords.isNotEmpty) {
        await _service.bulkDelete(
          collection: paymentsCollection,
          ids: paymentRecords.map((record) => record.id).toList(growable: false),
        );
      }

      final existingPlanner = await _service.get(collection: plannersCollection, id: plannerId);
      if (existingPlanner != null) {
        await _service.delete(
          collection: plannersCollection,
          id: plannerId,
          expectedVersion: existingPlanner.version,
        );
      }

      await _deleteInfoForPlanner(plannerId: plannerId);
      await appDb.touchLastActionDate();
    });
  }

  @override
  Future<Planner?> duplicatePlanner({
    required String originalPlannerId,
    required DateTime newStartDate,
    required DateTime newEndDate,
    String? newName,
  }) {
    return _guard(name: 'duplicatePlanner', () async {
      final original = await getPlannerById(originalPlannerId, withActualInfo: false);
      if (original == null) {
        throw Exception('Original planner with id "$originalPlannerId" not found');
      }

      final payments = await getPaymentsByPlannerId(plannerId: originalPlannerId);
      final newPlannerId = _uuid.v4();
      final plannerName = newName ?? '${original.name} (копия)';
      final duplicated = original.copyWith(
        id: newPlannerId,
        name: plannerName,
        dateStart: newStartDate,
        dateEnd: newEndDate,
        payments: const [],
        actualInfo: null,
        isGenerationAllowed: true,
      );

      await savePlanner(duplicated);

      for (final payment in payments) {
        final duplicatedPayment = payment.copyWith(
          paymentId: _uuid.v4(),
          plannerId: newPlannerId,
        );
        await _createPayment(duplicatedPayment);
      }

      await appDb.touchLastActionDate();
      return duplicated;
    });
  }

  @override
  Future<Payment?> getPaymentById({required String plannerId, required String paymentId}) {
    return _guard(name: 'getPaymentById', () async {
      final record = await _service.get(collection: paymentsCollection, id: paymentId);
      if (record == null) {
        return null;
      }
      final payment = _decodePaymentRecord(record);
      return payment.plannerId == plannerId ? payment : null;
    });
  }

  @override
  Future<List<Payment>> getPaymentsByPlannerId({required String plannerId}) {
    return _guard(name: 'getPaymentsByPlannerId', () async {
      final records = await _listAllRecords(
        paymentsCollection,
        filter: RecordFilter(equals: {'plannerId': plannerId}),
        sort: const SortOrder(field: 'date'),
      );
      return records.map(_decodePayment).toList(growable: false);
    });
  }

  @override
  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
    bool allowCreate = false,
  }) {
    return _guard(name: 'savePayment', () async {
      final normalized = payment.copyWith(plannerId: plannerId);
      final payload = _encodePayment(normalized);
      final existing = await _service.get(collection: paymentsCollection, id: normalized.paymentId);

      if (existing == null && !allowCreate) {
        throw Exception('Payment "${payment.paymentId}" is not linked with Planner "$plannerId"');
      }

      DataRecord record;
      if (existing == null) {
        record = await _service.create(
          collection: paymentsCollection,
          id: normalized.paymentId,
          payload: payload,
        );
      } else {
        record = await _service.update(
          collection: paymentsCollection,
          id: normalized.paymentId,
          expectedVersion: existing.version,
          payload: payload,
        );
      }

      await appDb.touchLastActionDate();
      return _decodePaymentRecord(record);
    });
  }

  @override
  Future<void> deletePayment({required String plannerId, required String paymentId}) {
    return _guard(name: 'deletePayment', () async {
      final existing = await _service.get(collection: paymentsCollection, id: paymentId);
      if (existing == null) {
        throw Exception('Payment "$paymentId" is not linked with Planner "$plannerId"');
      }
      final payment = _decodePaymentRecord(existing);
      if (payment.plannerId != plannerId) {
        throw Exception('Payment "$paymentId" is not linked with Planner "$plannerId"');
      }
      await _service.delete(
        collection: paymentsCollection,
        id: paymentId,
        expectedVersion: existing.version,
      );
      await appDb.touchLastActionDate();
    });
  }

  @override
  Future<Payment?> fixateRepeatedPayment({required String plannerId, required String paymentId}) {
    return _guard(name: 'fixateRepeatedPayment', () async {
      final existing = await _service.get(collection: paymentsCollection, id: paymentId);
      if (existing == null) {
        throw Exception('Cannot find payment with id "$paymentId" in planner "$plannerId"');
      }
      final payment = _decodePaymentRecord(existing);
      if (payment.plannerId != plannerId) {
        throw Exception('Payment "$paymentId" is not linked with Planner "$plannerId"');
      }
      if (!payment.isRepeatParent) {
        throw Exception('Payment should be repeated and parent');
      }

      final copied = payment.copyWith(
        paymentId: _uuid.v4(),
        repeat: DateTimeRepeat.noRepeat,
        dateStart: null,
        dateEnd: null,
      );
      final updatedOriginal = payment.copyWith(date: payment.repeat.next(payment.date));

      await _createPayment(copied);
      await _service.update(
        collection: paymentsCollection,
        id: payment.paymentId,
        expectedVersion: existing.version,
        payload: _encodePayment(updatedOriginal),
      );

      await appDb.touchLastActionDate();
      return copied;
    });
  }

  @override
  Future<PlannerActualInfo?> getPlannerActualInfo({required String plannerId}) {
    return _guard(name: 'getPlannerActualInfo', () async {
      final record = await _service.get(collection: plannerInfoCollection, id: plannerId);
      return record != null ? _decodePlannerActualInfo(record) : null;
    });
  }

  @override
  Future<PlannerActualInfo?> updatePlannerActualInfo({
    required String plannerId,
    required PlannerActualInfo plannerActualInfo,
  }) {
    return _guard(name: 'updatePlannerActualInfo', () async {
      final payload = plannerActualInfo.toJson();
      final existing = await _service.get(collection: plannerInfoCollection, id: plannerId);
      if (existing == null) {
        await _service.create(
          collection: plannerInfoCollection,
          id: plannerId,
          payload: payload,
        );
      } else {
        await _service.update(
          collection: plannerInfoCollection,
          id: plannerId,
          expectedVersion: existing.version,
          payload: payload,
        );
      }

      await appDb.touchLastActionDate();
      return plannerActualInfo;
    });
  }

  Future<void> _deleteInfoForPlanner({required String plannerId}) async {
    final existing = await _service.get(collection: plannerInfoCollection, id: plannerId);
    if (existing != null) {
      await _service.delete(
        collection: plannerInfoCollection,
        id: plannerId,
        expectedVersion: existing.version,
      );
    }
  }

  Future<void> _createPayment(Payment payment) async {
    await _service.create(
      collection: paymentsCollection,
      id: payment.paymentId,
      payload: _encodePayment(payment),
    );
  }

  Future<List<DataRecord>> _listAllRecords(
    String collection, {
    RecordFilter? filter,
    SortOrder? sort,
  }) async {
    final results = <DataRecord>[];
    String? cursor;
    do {
      final response = await _service.list(
        collection: collection,
        filter: filter,
        sort: sort,
        options: QueryOptions(limit: _pageSize, cursor: cursor),
      );
      results.addAll(response.records);
      cursor = response.nextCursor;
    } while (cursor != null);
    return results;
  }

  Planner _decodePlanner(DataRecord record) {
    final json = Map<String, dynamic>.from(record.payload);
    return Planner.fromJson(json);
  }

  PlannerActualInfo _decodePlannerActualInfo(DataRecord record) {
    final json = Map<String, dynamic>.from(record.payload);
    return PlannerActualInfo.fromJson(json);
  }

  Payment _decodePayment(DataRecord record) {
    final json = Map<String, dynamic>.from(record.payload);
    return Payment.fromJson(json);
  }

  Map<String, dynamic> _encodePlanner(Planner planner) {
    final sanitized = planner.copyWith(payments: const [], actualInfo: null);
    return sanitized.toJson();
  }

  Map<String, dynamic> _encodePayment(Payment payment) {
    return payment.toJson();
  }
}
