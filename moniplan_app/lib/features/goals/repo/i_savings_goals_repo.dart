import 'package:moniplan_app/features/goals/models/savings_goal.dart';

/// Работа с коллекцией целей накоплений в рамках планера.
abstract interface class ISavingsGoalsRepo {
  Future<List<SavingsGoal>> listByPlanner(String plannerId, {int limit});

  Future<void> upsert(SavingsGoal goal);

  Future<void> delete({required String plannerId, required String id});
}
