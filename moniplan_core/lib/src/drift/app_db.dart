import 'dart:io';

import 'package:moniplan_core/moniplan_core.dart';

typedef AppDbFactory = AppDb Function();

abstract class AppDb {
  static late AppDbFactory _factory;
  static AppDb? _instance;

  static set factory(AppDbFactory newFactory) {
    _factory = newFactory;
    _instance = _factory();
  }

  factory AppDb() {
    return _instance ??= _factory();
  }

  static AppDb get instance => _instance ??= _factory();

  MoniplanDriftDb get db;

  Future<void> close();

  Future<void> openDefault();

  Future<void> openFromFile(File dbFile);

  Future<void> overrideDefaultFromFile(File newDbFile);
}
