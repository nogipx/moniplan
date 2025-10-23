import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';
import 'package:rpc_dart_transports/rpc_dart_transports.dart';

import '../collections.dart';
import '../interfaces/i_app_db.dart';
import 'app_db.dart';
import 'app_db_worker.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  AppDbImpl({
    RpcLogger? log,
    bool inMemory = false,
    String? databaseName,
  })  : _log = log ?? RpcLogger('AppDbImpl'),
        _inMemory = inMemory,
        _databaseName = databaseName ?? 'app_db';

  final RpcLogger _log;
  final bool _inMemory;
  final String _databaseName;

  DataServiceClient? _client;
  IRpcTransport? _transport;
  void Function()? _killIsolate;
  Future<void>? _openFuture;

  DataServiceClient get _serviceClient {
    final client = _client;
    if (client == null) {
      throw StateError('Database service is not opened yet');
    }
    return client;
  }

  @override
  DataService get service => _serviceClient;

  bool get isOpen => _client != null;

  @override
  Future<void> open() async {
    if (_client != null) {
      return;
    }
    if (_openFuture != null) {
      await _openFuture;
      return;
    }
    _openFuture = _openInternal();
    try {
      await _openFuture;
    } finally {
      _openFuture = null;
    }
  }

  Future<void> _openInternal() async {
    try {
      final spawnResult = await RpcIsolateTransport.spawn(
        entrypoint: appDbWorkerEntrypoint,
        debugName: 'app-db-worker',
        customParams: <String, dynamic>{
          'inMemory': _inMemory,
          'databaseName': _databaseName,
        },
      );

      _transport = spawnResult.transport;
      _killIsolate = spawnResult.kill;
      _client = DataServiceFactory.createClient(
        transport: _transport!,
        debugLabel: 'AppDbClient',
      );

      await _warmup();
      await _ensureIndexes();
      notifyListeners();
    } on Object catch (error, stackTrace) {
      await _log.critical('Failed to open data service', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _warmup() async {
    try {
      await _serviceClient.list(
        collection: plannersCollection,
        options: const QueryOptions(limit: 1),
      );
    } on Object catch (error, stackTrace) {
      await _log.warning('Warmup failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _ensureIndexes() async {
    try {
      await _serviceClient.createCollectionIndex(
        collection: paymentsCollection,
        path: 'plannerId',
      );
    } on RpcDataError catch (error) {
      if (error.code != 'INVALID_ARGUMENT') {
        await _log.warning('Failed to create index', error: error);
      }
    } catch (error, stackTrace) {
      await _log.warning('Unexpected error creating index', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> overwriteWithBytes({required Uint8List bytes}) async {
    await open();
    try {
      final payload = base64Encode(bytes);
      await _serviceClient.importDatabase(payload: payload, replaceExisting: true);
      notifyListeners();
    } on Object catch (error, stackTrace) {
      await _log.error('overwriteWithBytes failed', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<Uint8List> exportBytes() async {
    await open();
    try {
      final response = await _serviceClient.exportDatabase();
      return Uint8List.fromList(base64Decode(response.payload));
    } on Object catch (error, stackTrace) {
      await _log.error('exportBytes failed', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    if (_openFuture != null) {
      await _openFuture;
    }
    final client = _client;
    if (client == null) {
      return;
    }

    try {
      await client.close();
    } catch (error, stackTrace) {
      await _log.warning('Failed to close client', error: error, stackTrace: stackTrace);
    }

    try {
      await _transport?.close();
    } catch (error, stackTrace) {
      await _log.warning('Failed to close transport', error: error, stackTrace: stackTrace);
    }

    try {
      _killIsolate?.call();
    } catch (error, stackTrace) {
      await _log.warning('Failed to kill isolate', error: error, stackTrace: stackTrace);
    }

    _client = null;
    _transport = null;
    _killIsolate = null;
    notifyListeners();
  }

  @override
  Future<void> touchLastActionDate() async {
    final now = DateTime.now().toUtc();
    const collection = globalLastUpdateCollection;
    const id = globalLastUpdateId;
    final payload = <String, dynamic>{
      'lastUpdateId': id,
      'updatedAt': now.toIso8601String(),
    };

    try {
      final existing = await _serviceClient.get(collection: collection, id: id);
      if (existing == null) {
        await _serviceClient.create(
          collection: collection,
          id: id,
          payload: payload,
        );
      } else {
        await _serviceClient.update(
          collection: collection,
          id: id,
          expectedVersion: existing.version,
          payload: payload,
        );
      }
    } catch (error, stackTrace) {
      await _log.warning('Failed to touch last action date', error: error, stackTrace: stackTrace);
    }
  }
}
