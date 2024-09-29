import 'dart:io';

import 'package:moniplan_core/moniplan_core.dart';

typedef AppDbFactory = AppDb Function();

abstract interface class AppDb {
  static late final AppDbFactory? _factory;

  // ignore: avoid_setters_without_getters
  static set factory(AppDbFactory newFactory) {
    _factory = newFactory;
  }

  factory AppDb() {
    if (_factory == null) {
      throw UnimplementedError('Db factory not setted.');
    }
    return _factory!();
  }

  MoniplanDriftDb get value;

  Future<void> close();

  Future<void> openDefault();

  Future<void> openFromFile(File dbFile);

  Future<void> overrideDefaultFromFile(File newDbFile);
}
