import 'dart:async';

import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/database/data_collection.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';
import 'package:uuid/uuid.dart';

import 'i_payment_planner_repo.dart';

class PlannerRepoDataService implements IPlannerRepo {
  PlannerRepoDataService({required IDataService dataService})
    : _planners = DataCollection<Planner>(
        collection: 'planners',
        dataService: dataService,
        fromJson: Planner.fromJson,
        toJson: (planner) =>
            planner.copyWith(payments: [], actualInfo: null).toJson(),
        idSelector: (planner) => planner.id,
        idField: 'id',
      ),
      _payments = DataCollection<Payment>(
        collection: 'payments',
        dataService: dataService,
        fromJson: Payment.fromJson,
        toJson: (payment) => payment.toJson(),
        idSelector: (payment) => payment.paymentId,
        idField: 'paymentId',
      ),
      _actualInfo = DataCollection<PlannerActualInfo>(
        collection: 'planner_actual_info',
        dataService: dataService,
        fromJson: PlannerActualInfo.fromJson,
        toJson: (info) => info.toJson(),
        idSelector: (info) => info.plannerId,
        idField: 'plannerId',
      ),
      _settings = DataCollection<PlannerSettings>(
        collection: 'planner_settings',
        dataService: dataService,
        fromJson: PlannerSettings.fromJson,
        toJson: (settings) => settings.toJson(),
        idSelector: (settings) => settings.id,
      );

  final DataCollection<Planner> _planners;
  final DataCollection<Payment> _payments;
  final DataCollection<PlannerActualInfo> _actualInfo;
  final DataCollection<PlannerSettings> _settings;

  static const _plannerSettingsId = 'current';

  @override
  Future<String?> getCurrentPlannerId() async {
    final settings = await _settings.get(_plannerSettingsId);
    return settings?.data.currentPlannerId;
  }

  @override
  Future<Planner?> getCurrentPlanner({bool withActualInfo = false}) async {
    final currentPlannerId = await getCurrentPlannerId();
    if (currentPlannerId == null) {
      return null;
    }
    return getPlannerById(currentPlannerId, withActualInfo: withActualInfo);
  }

  @override
  Future<void> setCurrentPlanner(String plannerId) async {
    final planner = await getPlannerById(plannerId);
    if (planner == null) {
      throw Exception('Planner "$plannerId" not found');
    }
    final settings = PlannerSettings(
      id: _plannerSettingsId,
      currentPlannerId: plannerId,
    );
    await _settings.upsert(settings);
  }

  @override
  Future<void> clearCurrentPlanner() async {
    final settings = await _settings.get(_plannerSettingsId);
    if (settings == null) {
      return;
    }
    await _settings.delete(_plannerSettingsId);
  }

  @override
  Future<Planner?> getPlannerById(
    String id, {
    bool withActualInfo = false,
  }) async {
    final record = await _planners.get(id);
    if (record == null) {
      return null;
    }

    final planner = record.data;
    final payments = await getPaymentsByPlannerId(plannerId: id);
    final actualInfo = withActualInfo
        ? await getPlannerActualInfo(plannerId: id)
        : null;

    return planner.copyWith(payments: payments, actualInfo: actualInfo);
  }

  @override
  Future<List<Planner>> getPlanners({
    bool withPayments = false,
    bool withActualInfo = true,
  }) async {
    final response = await _planners.list(
      options: const QueryOptions(limit: 1000),
    );
    final planners = response
        .map((record) => record.data)
        .toList(growable: false);

    if (!withPayments && !withActualInfo) {
      return planners;
    }

    final result = <Planner>[];
    for (final planner in planners) {
      final payments = withPayments
          ? await getPaymentsByPlannerId(plannerId: planner.id)
          : const <Payment>[];
      final actualInfo = withActualInfo
          ? await getPlannerActualInfo(plannerId: planner.id)
          : null;
      result.add(planner.copyWith(payments: payments, actualInfo: actualInfo));
    }
    return result;
  }

  @override
  Future<Planner?> savePlanner(Planner planner) async {
    if (!planner.isGenerationAllowed) {
      throw Exception(
        'Cannot persist generated planners. Only blueprints allowed to persist.',
      );
    }
    if (planner.id.isEmpty) {
      throw Exception('Invalid planner. Planner should have id.');
    }

    await _planners.upsert(planner);
    return planner;
  }

  @override
  Future<Payment?> getPaymentById({
    required String plannerId,
    required String paymentId,
  }) async {
    final record = await _payments.get(paymentId);
    if (record == null) {
      return null;
    }
    final payment = record.data;
    return payment.plannerId == plannerId ? payment : null;
  }

  @override
  Future<List<Payment>> getPaymentsByPlannerId({
    required String plannerId,
  }) async {
    final response = await _payments.list(
      filter: RecordFilter(equals: {'plannerId': plannerId}),
      options: const QueryOptions(limit: 5000),
    );
    return response.map((record) => record.data).toList(growable: false);
  }

  @override
  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
    bool allowCreate = false,
  }) async {
    final target = payment.copyWith(plannerId: plannerId, dateStart: null);
    final existing = await _payments.get(target.paymentId);

    if (existing == null && !allowCreate) {
      throw Exception(
        'Payment "${payment.paymentId}" is not linked with Planner "$plannerId"',
      );
    }

    await _payments.upsert(target);
    return target;
  }

  @override
  Future<void> deletePlanner(String plannerId) async {
    final payments = await getPaymentsByPlannerId(plannerId: plannerId);
    if (payments.isNotEmpty) {
      await _payments.bulkDelete(payments.map((p) => p.paymentId).toList());
    }
    final currentPlannerId = await getCurrentPlannerId();
    if (currentPlannerId == plannerId) {
      await clearCurrentPlanner();
    }
    await _planners.delete(plannerId);
    await _actualInfo.delete(plannerId);
  }

  @override
  Future<Planner?> duplicatePlanner({
    required String originalPlannerId,
    required DateTime newStartDate,
    required DateTime newEndDate,
    String? newName,
  }) async {
    final original = await getPlannerById(
      originalPlannerId,
      withActualInfo: false,
    );
    if (original == null) {
      throw Exception(
        'Original planner with id "$originalPlannerId" not found',
      );
    }

    final originalPayments = await getPaymentsByPlannerId(
      plannerId: originalPlannerId,
    );
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
  }

  @override
  Future<void> deletePayment({
    required String plannerId,
    required String paymentId,
  }) async {
    final payment = await getPaymentById(
      plannerId: plannerId,
      paymentId: paymentId,
    );
    if (payment == null) {
      throw Exception(
        'Payment "$paymentId" is not linked with Planner "$plannerId"',
      );
    }
    await _payments.delete(paymentId);
  }

  @override
  Future<Payment?> fixateRepeatedPayment({
    required String plannerId,
    required String paymentId,
  }) async {
    final record = await _payments.get(paymentId);
    final payment = record?.data;
    if (payment == null || payment.plannerId != plannerId) {
      throw Exception(
        'Cannot find payment with id "$paymentId" in planner "$plannerId"',
      );
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

    await _payments.upsert(copiedPayment.copyWith(plannerId: plannerId));
    await _payments.upsert(updatedOriginalPayment);

    return copiedPayment.copyWith(plannerId: plannerId);
  }

  @override
  Future<PlannerActualInfo?> getPlannerActualInfo({
    required String plannerId,
  }) async {
    final record = await _actualInfo.get(plannerId);
    return record?.data;
  }

  @override
  Future<PlannerActualInfo?> updatePlannerActualInfo({
    required String plannerId,
    required PlannerActualInfo plannerActualInfo,
  }) async {
    final info = plannerActualInfo.copyWith(plannerId: plannerId);
    await _actualInfo.upsert(info);
    return plannerActualInfo;
  }
}
