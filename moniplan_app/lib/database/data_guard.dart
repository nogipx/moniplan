import 'package:rpc_dart/logger.dart';

/// Wraps a data operation with logging on error while preserving the original exception.
Future<T> guardDataService<T>({
  required RpcLogger log,
  required String operation,
  required Future<T> Function() run,
}) async {
  try {
    return await run();
  } on Object catch (error, stackTrace) {
    log.error('Failed operation: $operation', error: error, stackTrace: stackTrace);
    rethrow;
  }
}
