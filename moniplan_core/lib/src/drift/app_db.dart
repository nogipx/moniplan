// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_core/moniplan_core.dart';

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

  static IAppDb get instance => _instance ??= _factory() as AppDb;

  MoniplanDriftDb get db;
}
