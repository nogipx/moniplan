import 'package:moniplan_domain/moniplan_domain.dart';

abstract interface class IAppDi {
  Future<void> setup();

  IAppDb getDb();

  IPlannerRepo getPlannerRepo();

  IMonisyncRepo getMonisyncRepo();
}
