import 'package:moniplan_app/database/_index.dart';
import 'package:rpc_dart/logger.dart';

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

  static IAppDb get instance => _instance ??= _factory() as AppDb;

  MoniplanDriftDb get db;
}
