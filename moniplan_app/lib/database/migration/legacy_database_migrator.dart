import 'dart:async';
import 'dart:io';

import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/database/collections.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';
import 'package:sqlite3/sqlite3.dart';

class LegacyDatabaseMigrator {
  LegacyDatabaseMigrator({
    required this.appDb,
    RpcLogger? logger,
  }) : _log = logger ?? RpcLogger('LegacyDatabaseMigrator');

  final AppDb appDb;
  final RpcLogger _log;

  Future<void> migrate({
    required String legacyDatabasePath,
    bool clearBeforeImport = true,
  }) async {
    final legacyFile = File(legacyDatabasePath);
    if (!legacyFile.existsSync()) {
      throw ArgumentError('Legacy database not found at "$legacyDatabasePath"');
    }

    final database = sqlite3.open(legacyDatabasePath, mode: OpenMode.readOnly);
    try {
      final snapshot = _readSnapshot(database);

      await appDb.open();
      final service = appDb.service;

      if (clearBeforeImport) {
        await _clearCollections(service);
      }

      for (final planner in snapshot.planners) {
        await _upsert(
          service,
          collection: plannersCollection,
          id: planner.id,
          payload: _encodePlanner(planner),
        );
      }

      for (final payment in snapshot.payments) {
        await _upsert(
          service,
          collection: paymentsCollection,
          id: payment.paymentId,
          payload: payment.toJson(),
        );
      }

      for (final entry in snapshot.actualInfos.entries) {
        await _upsert(
          service,
          collection: plannerInfoCollection,
          id: entry.key,
          payload: entry.value.toJson(),
        );
      }

      if (snapshot.lastUpdate != null) {
        await _upsert(
          service,
          collection: globalLastUpdateCollection,
          id: globalLastUpdateId,
          payload: {
            'lastUpdateId': globalLastUpdateId,
            'updatedAt': snapshot.lastUpdate!.toUtc().toIso8601String(),
          },
        );
      }

      await _log.info(
        'Legacy migration completed: '
        '${snapshot.planners.length} planners, '
        '${snapshot.payments.length} payments, '
        '${snapshot.actualInfos.length} planner infos.',
      );
    } finally {
      database.dispose();
    }
  }

  Future<void> _clearCollections(DataService service) async {
    const collections = [
      paymentsCollection,
      plannersCollection,
      plannerInfoCollection,
      globalLastUpdateCollection,
    ];

    for (final collection in collections) {
      final records = await _listAllRecords(service, collection);
      if (records.isEmpty) {
        continue;
      }

      await service.bulkDelete(
        collection: collection,
        ids: records.map((record) => record.id).toList(growable: false),
      );
    }
  }

  Future<void> _upsert(
    DataService service, {
    required String collection,
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final existing = await service.get(collection: collection, id: id);
      if (existing == null) {
        await service.create(collection: collection, id: id, payload: payload);
      } else {
        await service.update(
          collection: collection,
          id: id,
          expectedVersion: existing.version,
          payload: payload,
        );
      }
    } on RpcDataError catch (error, stackTrace) {
      unawaited(_log.error('Failed to upsert "$collection/$id"', error: error, stackTrace: stackTrace));
      rethrow;
    }
  }

  Future<List<DataRecord>> _listAllRecords(DataService service, String collection) async {
    final results = <DataRecord>[];
    String? cursor;
    do {
      final response = await service.list(
        collection: collection,
        options: QueryOptions(limit: 200, cursor: cursor),
      );
      results.addAll(response.records);
      cursor = response.nextCursor;
    } while (cursor != null);
    return results;
  }

  Map<String, dynamic> _encodePlanner(Planner planner) {
    return planner.copyWith(payments: const [], actualInfo: null).toJson();
  }

  _LegacySnapshot _readSnapshot(Database database) {
    final planners = _readPlanners(database);
    final payments = _readPayments(database);
    final actualInfos = _readPlannerInfos(database);
    final lastUpdate = _readGlobalLastUpdate(database);
    return _LegacySnapshot(
      planners: planners,
      payments: payments,
      actualInfos: actualInfos,
      lastUpdate: lastUpdate,
    );
  }

  List<Planner> _readPlanners(Database database) {
    final rows = database.select('SELECT * FROM payment_planners_drift_table');
    final planners = <Planner>[];

    for (final row in rows) {
      final id = _readString(row, 'plannerId');
      final start = _readDateTime(row, 'dateStart');
      final end = _readDateTime(row, 'dateEnd');
      if (id == null || start == null || end == null) {
        unawaited(_log.warning('Skipped planner row because of missing required fields: $row'));
        continue;
      }

      planners.add(
        Planner(
          id: id,
          name: _readString(row, 'plannerName') ?? '',
          dateStart: start,
          dateEnd: end,
          initialBudget: _readNum(row, 'initialBudget') ?? 0,
          isGenerationAllowed: _readBool(row, 'isGenerationAllowed') ?? true,
        ),
      );
    }

    return planners;
  }

  List<Payment> _readPayments(Database database) {
    final rows = database.select('SELECT * FROM payments_composed_drift_table');
    final payments = <Payment>[];

    for (final row in rows) {
      final paymentId = _readString(row, 'paymentId');
      final plannerId = _readString(row, 'plannerId') ?? '';
      final currencyCode = _readString(row, 'currencyCode');
      final currencyPrecision = _readInt(row, 'currencyPrecision');
      final date = _readDateTime(row, 'date');
      if (paymentId == null || currencyCode == null || currencyPrecision == null || date == null) {
        unawaited(_log.warning('Skipped payment row because of missing required fields: $row'));
        continue;
      }

      final details = PaymentDetails(
        name: _readString(row, 'paymentName') ?? '',
        note: _readString(row, 'paymentNote') ?? '',
        type: PaymentType.from(_readInt(row, 'paymentTypeId')),
        currency: CurrencyData.create(currencyCode, currencyPrecision),
        money: _readNum(row, 'paymentMoney') ?? 0,
        tax: (_readNum(row, 'paymentTax') ?? 0).toDouble(),
        tags: _parseTags(_readString(row, 'paymentTags')),
      );

      payments.add(
        Payment(
          paymentId: paymentId,
          plannerId: plannerId,
          isEnabled: _readBool(row, 'isEnabled') ?? true,
          isDone: _readBool(row, 'isDone') ?? false,
          details: details,
          date: date,
          dateMoneyReserved: _readDateTime(row, 'dateMoneyReserved'),
          originalPaymentId: _readString(row, 'originalPaymentId'),
          dateStart: _readDateTime(row, 'dateStart'),
          dateEnd: _readDateTime(row, 'dateEnd'),
          repeat: DateTimeRepeat.from(_readInt(row, 'dateTimeRepeatId')),
        ),
      );
    }

    return payments;
  }

  Map<String, PlannerActualInfo> _readPlannerInfos(Database database) {
    final rows = database.select('SELECT * FROM planner_actual_info_drift_table');
    final infos = <String, PlannerActualInfo>{};

    for (final row in rows) {
      final plannerId = _readString(row, 'plannerId');
      final updatedAt = _readDateTime(row, 'updatedAt');
      if (plannerId == null || updatedAt == null) {
        unawaited(_log.warning('Skipped planner actual info because of missing required fields: $row'));
        continue;
      }

      infos[plannerId] = PlannerActualInfo(
        plannerId: plannerId,
        updatedAt: updatedAt,
        completedCount: _readInt(row, 'completedCount') ?? 0,
        waitingCount: _readInt(row, 'waitingCount') ?? 0,
        disabledCount: _readInt(row, 'disabledCount') ?? 0,
        totalCount: _readInt(row, 'totalCount') ?? 0,
        updatedAtBudget: _readNum(row, 'updatedAtBudget') ?? 0,
      );
    }

    return infos;
  }

  DateTime? _readGlobalLastUpdate(Database database) {
    final rows = database.select('SELECT * FROM global_last_update LIMIT 1');
    if (rows.isEmpty) {
      return null;
    }

    return _readDateTime(rows.first, 'updatedAt');
  }

  Set<String> _parseTags(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }
    return raw
        .split('|')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet();
  }

  String? _readString(Row row, String column) {
    if (!_hasColumn(row, column)) {
      return null;
    }
    final value = row[column];
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  int? _readInt(Row row, String column) {
    if (!_hasColumn(row, column)) {
      return null;
    }
    final value = row[column];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  num? _readNum(Row row, String column) {
    if (!_hasColumn(row, column)) {
      return null;
    }
    final value = row[column];
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  bool? _readBool(Row row, String column) {
    if (!_hasColumn(row, column)) {
      return null;
    }
    final value = row[column];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return null;
  }

  DateTime? _readDateTime(Row row, String column) {
    if (!_hasColumn(row, column)) {
      return null;
    }
    final value = row[column];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  bool _hasColumn(Row row, String column) {
    return row.columnNames.contains(column);
  }
}

class _LegacySnapshot {
  const _LegacySnapshot({
    required this.planners,
    required this.payments,
    required this.actualInfos,
    required this.lastUpdate,
  });

  final List<Planner> planners;
  final List<Payment> payments;
  final Map<String, PlannerActualInfo> actualInfos;
  final DateTime? lastUpdate;
}
