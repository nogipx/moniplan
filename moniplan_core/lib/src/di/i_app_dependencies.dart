import 'package:moniplan_core/moniplan_core.dart';

abstract interface class AppDi {
  static late final AppDi instance;

  Future<void> setup();

  AppDb getDb();

  IPlannerRepo getPlannerRepo();

  IMonisyncRepo getMonisyncRepo();
}
