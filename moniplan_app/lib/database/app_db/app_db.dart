import 'package:rpc_dart_data/rpc_dart_data.dart';

import '../interfaces/i_app_db.dart';
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
    final db = AppDbImpl(inMemory: true);
    return db;
  }

  static AppDb get instance => _instance ??= _factory() as AppDb;

  DataService get service;

  bool get isOpen;

  Future<void> touchLastActionDate();
}
