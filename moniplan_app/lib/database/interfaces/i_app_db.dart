import 'dart:typed_data';

import 'package:rpc_dart_data/rpc_dart_data.dart';

typedef IAppDbFactory = IAppDb Function();

abstract class IAppDb {
  /// Клиент rpc_dart_data для CRUD-операций.
  ///
  /// Доступен только после [open].
  DataServiceClient get dataService;

  Future<void> close();

  Future<void> open();

  Future<void> overwriteWithBytes({required Uint8List bytes});

  Future<Uint8List> exportBytes();
}
