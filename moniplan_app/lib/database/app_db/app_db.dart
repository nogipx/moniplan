import 'package:moniplan_app/database/interfaces/i_app_db.dart';
import 'package:rpc_dart/logger.dart';

import 'app_db_impl.dart';

abstract class AppDb extends IAppDb {
  static late IAppDbFactory _factory;
  static AppDb? _instance;

  static void setFactory(IAppDbFactory newFactory) {
    _factory = newFactory;
    _instance = _factory() as AppDb;
  }

  factory AppDb() {
    return _instance ??= _factory() as AppDb;
  }

  static AppDbImpl detachedInMemory() {
    final db = AppDbImpl(inMemory: true, log: RpcLogger('TempAppDb'));
    return db;
  }

  static AppDb get instance => _instance ??= _factory() as AppDb;
}
