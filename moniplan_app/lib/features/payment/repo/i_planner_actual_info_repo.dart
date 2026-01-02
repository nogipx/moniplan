import 'package:moniplan_app/core/_index.dart';

/// Работа только с коллекцией актуальной информации планнера.
abstract interface class IPlannerActualInfoRepo {
  Future<PlannerActualInfo?> get(String plannerId);

  Future<void> upsert(PlannerActualInfo actualInfo);

  Future<void> delete(String plannerId);
}
