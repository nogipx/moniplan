import 'package:moniplan_app/core/_index.dart';

/// Работа только с коллекцией планнеров.
abstract interface class IPlannersRepo {
  Future<List<Planner>> list({int limit});

  Future<Planner?> getById(String id);

  Future<void> upsert(Planner planner);

  Future<void> delete(String id);
}
