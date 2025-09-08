// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_app/database/_index.dart';
import 'package:rpc_dart/logger.dart';

abstract class AppDb extends IAppDb {
  static late IAppDbFactory _factory;
  static AppDb? _instance;

  static set factory(IAppDbFactory newFactory) {
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
