import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:moniplan_app/database/interfaces/i_app_db.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rpc_dart/rpc_dart.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';
import 'package:rpc_dart_transports/rpc_dart_transports.dart';

/// Универсальный AppDb поверх rpc_dart_data. Использует SQLite файл на IO и OPFS/IndexedDB на web.
class AppDbImpl extends ChangeNotifier implements IAppDb {
  AppDbImpl({RpcLogger? log, bool inMemory = false})
    : _log = log ?? RpcLogger('AppDbImpl'),
      _inMemory = inMemory;

  final bool _inMemory;
  final RpcLogger _log;

  DatabaseConnection? _connection;
  SqliteDataStorageAdapter? _storage;
  SqliteDataRepository? _repository;
  _AppDbEnvironment? _env;
  String? _dbPath;

  @override
  IDataService get dataService {
    final client = _env?.client;
    if (client == null) {
      throw StateError('Database not opened');
    }
    return client;
  }

  @override
  Future<void> open() async {
    if (_env != null) {
      return;
    }

    try {
      final dbPath = !_inMemory && !kIsWeb ? await _resolveDbPath() : null;
      final options = _buildOptions(nativePath: dbPath);
      _env = kIsWeb ? await _openLocalEnvironment(options) : await _openIsolateEnvironment(options);

      notifyListeners();
    } on Object catch (error, trace) {
      _log.error('open failed', error: error, stackTrace: trace);
      rethrow;
    }
  }

  @override
  Future<Uint8List> exportSqlite() async {
    if (kIsWeb || _inMemory) {
      throw UnsupportedError('SQLite export is not available for in-memory/web storage');
    }

    await open();
    final path = await _resolveDbPath();
    final file = File(path);
    if (file.existsSync()) {
      return file.readAsBytesSync();
    }

    throw StateError('SQLite file is missing at $path');
  }

  @override
  Future<void> importSqlite({required Uint8List bytes}) async {
    if (kIsWeb || _inMemory) {
      throw UnsupportedError('SQLite import is not available for in-memory/web storage');
    }

    await _close();
    final path = await _resolveDbPath();
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    await open();
    notifyListeners();
  }

  @override
  Future<void> close() async {
    await _close();
    notifyListeners();
  }

  Future<void> _close() async {
    try {
      await _env?.dispose();
    } finally {
      _env = null;
      await _disposeLocalResources();
    }
  }

  Future<_AppDbEnvironment> _openIsolateEnvironment(
    SqliteConnectionOptions options,
  ) async {
    final config = _AppDbIsolateConfig(
      inMemory: _inMemory,
      nativePath: options.nativePath,
    );

    final isolate = await RpcIsolateTransport.spawn(
      entrypoint: _appDbIsolateEntrypoint,
      customParams: config.toMap(),
      isolateId: 'app-db',
      debugName: 'AppDbIsolate',
    );

    try {
      final client = DataServiceFactory.createClient(
        transport: isolate.transport,
        transferMode: RpcDataTransferMode.zeroCopy,
        debugLabel: 'AppDbClient',
      );

      return _AppDbEnvironment(
        client: client,
        dispose: () async {
          await client.close();
          isolate.kill();
        },
      );
    } catch (_) {
      isolate.kill();
      rethrow;
    }
  }

  Future<_AppDbEnvironment> _openLocalEnvironment(
    SqliteConnectionOptions options,
  ) async {
    _connection = _inMemory
        ? await openInMemoryDb(options: options)
        : await _openPersistentConnection(options);

    _storage = SqliteDataStorageAdapter.connection(
      _connection!,
      isInMemory: _inMemory,
    );
    await _storage!.ensureReady();

    _repository = SqliteDataRepository(storage: _storage!);
    final env = await DataServiceFactory.inMemory(repository: _repository);

    return _AppDbEnvironment(
      client: env.client,
      dispose: () async {
        await env.dispose();
        await _disposeLocalResources();
      },
    );
  }

  Future<DatabaseConnection> _openPersistentConnection(
    SqliteConnectionOptions options,
  ) async {
    if (kIsWeb) {
      return openFileDb(options: options);
    }

    final path = await _resolveDbPath();
    final opts = SqliteConnectionOptions(
      nativePath: path,
      nativeFileName: options.nativeFileName,
      nativeTempDirectory: options.nativeTempDirectory,
      webSqliteWasmUri: options.webSqliteWasmUri,
      webWorkerUri: options.webWorkerUri,
      webDatabaseName: options.webDatabaseName,
      webVfsMode: options.webVfsMode,
      webFileName: options.webFileName,
      webCustomVfs: options.webCustomVfs,
    );
    return openFileDb(options: opts);
  }

  SqliteConnectionOptions _buildOptions({String? nativePath}) {
    final wasmUri = Uri.parse('sqlite3mc.wasm');
    return SqliteConnectionOptions(
      nativePath: nativePath,
      webSqliteWasmUri: wasmUri,
    );
  }

  Future<String> _resolveDbPath() async {
    if (_dbPath != null) {
      return _dbPath!;
    }

    if (_inMemory) {
      final dir = await getTemporaryDirectory();
      _dbPath = p.join(dir.path, 'app_db_temp.sqlite');
      return _dbPath!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _dbPath = p.join(dir.path, 'app.db');
    return _dbPath!;
  }

  Future<void> _disposeLocalResources() async {
    try {
      if (_repository != null) {
        await _repository!.dispose();
      } else if (_storage != null) {
        await _storage!.dispose();
      } else if (_connection != null) {
        await _connection!.close();
      }
    } finally {
      _repository = null;
      _storage = null;
      _connection = null;
    }
  }
}

class _AppDbEnvironment {
  _AppDbEnvironment({
    required this.client,
    required Future<void> Function() dispose,
  }) : _dispose = dispose;

  final IDataService client;
  final Future<void> Function() _dispose;

  Future<void> dispose() => _dispose();
}

class _AppDbIsolateConfig {
  const _AppDbIsolateConfig({
    required this.inMemory,
    this.nativePath,
  });

  final bool inMemory;
  final String? nativePath;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'inMemory': inMemory,
    'nativePath': nativePath,
  };

  factory _AppDbIsolateConfig.fromMap(Map<String, dynamic> map) {
    return _AppDbIsolateConfig(
      inMemory: map['inMemory'] as bool? ?? false,
      nativePath: map['nativePath'] as String?,
    );
  }

  SqliteConnectionOptions toOptions() {
    return SqliteConnectionOptions(nativePath: nativePath);
  }
}

@pragma('vm:entry-point')
Future<void> _appDbIsolateEntrypoint(
  IRpcTransport transport,
  Map<String, dynamic> customParams,
) async {
  final log = RpcLogger('AppDbIsolate');
  final config = _AppDbIsolateConfig.fromMap(customParams);
  final shutdown = Completer<void>();

  transport.incomingMessages.listen(
    (_) {},
    onDone: () {
      if (!shutdown.isCompleted) {
        shutdown.complete();
      }
    },
  );

  DatabaseConnection? connection;
  SqliteDataStorageAdapter? storage;
  SqliteDataRepository? repository;
  DataServiceServer? server;

  try {
    final options = config.toOptions();
    if (!config.inMemory && options.nativePath == null) {
      throw StateError('nativePath is required for persistent database in isolate');
    }

    connection = config.inMemory
        ? await openInMemoryDb(options: options)
        : await openFileDb(options: options);

    storage = SqliteDataStorageAdapter.connection(
      connection,
      isInMemory: config.inMemory,
    );
    await storage.ensureReady();

    repository = SqliteDataRepository(storage: storage);

    server = DataServiceFactory.createServer(
      transport: transport,
      repository: repository,
      transferMode: RpcDataTransferMode.zeroCopy,
      debugLabel: 'AppDbServer',
    );
    await server.start();

    await shutdown.future;
  } catch (error, stackTrace) {
    log.error(
      'Failed to start App DB isolate',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  } finally {
    await server?.close();
    await repository?.dispose();
    if (repository == null && storage != null) {
      await storage.dispose();
    }
    if (connection != null && storage == null && repository == null) {
      await connection.close();
    }
  }
}
