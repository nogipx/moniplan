import 'dart:async';

import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_transports/rpc_dart_transports.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

/// Entry point for the background isolate that hosts the data service.
void appDbWorkerEntrypoint(IRpcTransport transport, Map<String, dynamic> params) async {
  final logger = RpcLogger('AppDbWorker');
  final bool inMemory = params['inMemory'] as bool? ?? false;
  final String databaseName = params['databaseName'] as String? ?? 'app_db';

  DataRepository repository;
  DriftDataStorageAdapter? storage;

  try {
    if (inMemory) {
      repository = InMemoryDataRepository();
    } else {
      final options = DriftConnectionOptions(
        nativeFileName: '$databaseName.sqlite',
        webDatabaseName: databaseName,
      );
      storage = await openMainStorage(options: options);
      repository = DriftDataRepository(storage: storage);
    }

    final server = DataServiceFactory.createServer(
      transport: transport,
      repository: repository,
      debugLabel: 'AppDbDataService',
    );
    await server.start();

    final done = Completer<void>();
    transport.incomingMessages.listen(
      (_) {},
      onError: (error, stackTrace) async {
        await logger.error('Transport error: $error', error: error, stackTrace: stackTrace);
      },
      onDone: () => done.complete(),
      cancelOnError: false,
    );

    await done.future;
    await server.close();
  } catch (error, stackTrace) {
    await logger.critical('Worker crashed: $error', error: error, stackTrace: stackTrace);
    rethrow;
  } finally {
    try {
      await storage?.dispose();
    } catch (_) {}
  }
}
