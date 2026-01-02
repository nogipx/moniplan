import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

import 'data_guard.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T model);

/// Typed wrapper around a single IDataService collection.
class DataCollection<T> {
  DataCollection({
    required this.collection,
    required this.dataService,
    required this.fromJson,
    required this.toJson,
    required this.idSelector,
    this.idField = 'id',
    RpcLogger? customLog,
  }) : log = customLog ?? RpcLogger('DataCollection:$collection');

  final String collection;
  final IDataService dataService;
  final RpcLogger log;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final String Function(T model) idSelector;
  final String idField;

  Versioned<T> _fromRecord(DataRecord record) {
    final payload = Map<String, dynamic>.from(record.payload)..[idField] = record.id;
    return Versioned(fromJson(payload), record.version);
  }

  Future<Versioned<T>?> get(String id) async {
    return guardDataService(
      log: log,
      operation: 'get:$collection/$id',
      run: () async {
        final record = await dataService.get(collection: collection, id: id);
        return record == null ? null : _fromRecord(record);
      },
    );
  }

  Future<List<Versioned<T>>> list({
    RecordFilter? filter,
    QueryOptions? options,
  }) async {
    return guardDataService(
      log: log,
      operation: 'list:$collection',
      run: () async {
        final response = await dataService.list(
          collection: collection,
          filter: filter,
          options: options ?? const QueryOptions(limit: 1000),
        );
        return response.records.map(_fromRecord).toList(growable: false);
      },
    );
  }

  Future<T> upsert(T model) async {
    final id = idSelector(model);
    final payload = toJson(model);
    return guardDataService(
      log: log,
      operation: 'upsert:$collection/$id',
      run: () async {
        final existing = await dataService.get(collection: collection, id: id);

        if (existing == null) {
          await dataService.create(collection: collection, id: id, payload: payload);
        } else {
          await dataService.update(
            collection: collection,
            id: id,
            expectedVersion: existing.version,
            payload: payload,
          );
        }
        return model;
      },
    );
  }

  Future<void> delete(String id) {
    return guardDataService(
      log: log,
      operation: 'delete:$collection/$id',
      run: () => dataService.delete(collection: collection, id: id),
    );
  }

  Future<void> bulkDelete(List<String> ids) {
    return guardDataService(
      log: log,
      operation: 'bulkDelete:$collection/${ids.length}',
      run: () => dataService.bulkDelete(collection: collection, ids: ids),
    );
  }
}

class Versioned<T> {
  const Versioned(this.data, this.version);

  final T data;
  final int version;
}
