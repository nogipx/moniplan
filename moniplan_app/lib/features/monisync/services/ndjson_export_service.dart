import 'dart:convert';

import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';

typedef DateTimeProvider = DateTime Function();

class NdjsonExportResult {
  const NdjsonExportResult({
    required this.content,
    required this.collectionCount,
    required this.recordCount,
  });

  final String content;
  final int collectionCount;
  final int recordCount;
}

/// Собирает данные приложения в NDJSON формате, аналогичном `format.json`.
class NdjsonExportService {
  NdjsonExportService({required this.appDb, DateTimeProvider? now}) : _now = now ?? DateTime.now;

  final AppDb appDb;
  final DateTimeProvider _now;

  static const _formatVersion = '2.0.0';
  static const _paymentsCollection = 'payments';
  static const _actualInfoCollection = 'planner_actual_info';
  static const _plannersCollection = 'planners';

  Future<NdjsonExportResult> export() async {
    await appDb.open();

    // Загружаем все сущности из базы.
    final paymentsDto = await appDb.db.managers.paymentsComposedDriftTable.get();
    final plannersDto = await appDb.db.managers.paymentPlannersDriftTable.get();
    final actualInfoDto = await appDb.db.managers.plannerActualInfoDriftTable.get();

    // Приводим к доменным моделям.
    final payments = paymentsDto.map(const PaymentMapperDrift().toDomain).toList()
      ..sort(
        (a, b) {
          final byDate = a.date.compareTo(b.date);
          if (byDate != 0) {
            return byDate;
          }
          return a.paymentId.compareTo(b.paymentId);
        },
      );

    final planners = plannersDto.map(const PlannerMapperDrift().toDomain).toList()
      ..sort((a, b) => a.dateStart.compareTo(b.dateStart));

    final actualInfos = actualInfoDto.map(const PlannerActualInfoMapper().toDomain).toList()
      ..sort((a, b) => a.plannerId.compareTo(b.plannerId));

    // Формируем NDJSON.
    final generatedAt = _now().toUtc().toIso8601String();
    final buffer = StringBuffer();

    buffer.writeln(
      jsonEncode({
        'type': 'header',
        'formatVersion': _formatVersion,
        'generatedAt': generatedAt,
      }),
    );

    var recordCount = 0;
    var collectionCount = 0;

    String? _toIso(DateTime? dateTime) => dateTime?.toIso8601String();

    Map<String, dynamic> _wrapRecord({
      required String id,
      required String collection,
      required Map<String, dynamic> payload,
      String? createdAt,
      String? updatedAt,
    }) {
      // В БД нет явных created/updated, поэтому по умолчанию используем момент экспорта.
      final created = createdAt ?? generatedAt;
      final updated = updatedAt ?? created;
      return <String, dynamic>{
        'id': id,
        'collection': collection,
        'payload': payload,
        'version': 1,
        'createdAt': created,
        'updatedAt': updated,
      };
    }

    void _writeCollection(String name, Iterable<Map<String, dynamic>> records) {
      buffer.writeln(jsonEncode({'type': 'collection', 'name': name}));
      for (final record in records) {
        buffer.writeln(jsonEncode({'type': 'record', 'data': record}));
        recordCount++;
      }
      buffer.writeln(jsonEncode({'type': 'collectionEnd', 'name': name}));
      collectionCount++;
    }

    _writeCollection(
      _paymentsCollection,
      payments.map((payment) {
        final details = payment.details.toJson();
        final tags = payment.details.tags.toList()..sort();
        details['tags'] = tags;

        final payload = <String, dynamic>{
          'paymentId': payment.paymentId,
          'details': details,
          'date': payment.date.toIso8601String(),
          'plannerId': payment.plannerId,
          'isEnabled': payment.isEnabled,
          'isDone': payment.isDone,
          'dateMoneyReserved': _toIso(payment.dateMoneyReserved),
          'originalPaymentId': payment.originalPaymentId,
          'dateStart': _toIso(payment.dateStart),
          'dateEnd': _toIso(payment.dateEnd),
          'repeat': payment.repeat.id,
        };

        return _wrapRecord(
          id: payment.paymentId,
          collection: _paymentsCollection,
          payload: payload,
        );
      }),
    );

    _writeCollection(
      _actualInfoCollection,
      actualInfos.map((info) {
        final payload = info.toJson();
        final updatedAt = payload['updatedAt'] as String?;
        return _wrapRecord(
          id: info.plannerId,
          collection: _actualInfoCollection,
          payload: payload,
          createdAt: updatedAt,
          updatedAt: updatedAt,
        );
      }),
    );

    _writeCollection(
      _plannersCollection,
      planners.map((planner) {
        final payload = <String, dynamic>{
          'id': planner.id,
          'dateStart': planner.dateStart.toIso8601String(),
          'dateEnd': planner.dateEnd.toIso8601String(),
          'isGenerationAllowed': planner.isGenerationAllowed,
          'name': planner.name,
          'payments': <dynamic>[], // платежи экспортируются отдельно
          'initialBudget': planner.initialBudget,
          'actualInfo': null, // актуальная информация вынесена в отдельную коллекцию
        };

        final plannerCreatedAt = _toIso(planner.dateStart);
        return _wrapRecord(
          id: planner.id,
          collection: _plannersCollection,
          payload: payload,
          createdAt: plannerCreatedAt,
          updatedAt: plannerCreatedAt,
        );
      }),
    );

    buffer.writeln(
      jsonEncode({
        'type': 'footer',
        'collectionCount': collectionCount,
        'recordCount': recordCount,
      }),
    );

    return NdjsonExportResult(
      content: buffer.toString(),
      collectionCount: collectionCount,
      recordCount: recordCount,
    );
  }
}
