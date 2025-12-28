import 'dart:typed_data';

import 'package:rpc_dart_data/rpc_dart_data.dart';

typedef IAppDbFactory = IAppDb Function();

abstract class IAppDb {
  /// Клиент rpc_dart_data для CRUD-операций.
  ///
  /// Доступен только после [open].
  IDataService get dataService;

  Future<void> close();

  Future<void> open();

  /// Экспортирует SQLite-файл базы данных (только для persistent-хранилища).
  Future<Uint8List> exportSqlite();

  /// Импортирует SQLite-файл базы данных (только для persistent-хранилища).
  Future<void> importSqlite({required Uint8List bytes});
}
