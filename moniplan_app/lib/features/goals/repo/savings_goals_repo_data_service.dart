import 'package:moniplan_app/features/goals/models/savings_goal.dart';
import 'package:moniplan_app/features/goals/repo/i_savings_goals_repo.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

class SavingsGoalsRepoDataService implements ISavingsGoalsRepo {
  SavingsGoalsRepoDataService({required IDataService dataService})
      : _goals = DataServiceCollection<SavingsGoal>(
          collection: 'savings_goals',
          dataService: dataService,
          fromJson: SavingsGoal.fromJson,
          toJson: (goal) => goal.toJson(),
          idSelector: (goal) => goal.id,
        );

  final IDataServiceCollection<SavingsGoal> _goals;

  @override
  Future<List<SavingsGoal>> listByPlanner(
    String plannerId, {
    int limit = 1000,
  }) async {
    final response = await _goals.list(
      filter: RecordFilter(equals: {'plannerId': plannerId}),
      options: QueryOptions(limit: limit),
    );
    return response.map((record) => record.data).toList(growable: false);
  }

  @override
  Future<void> upsert(SavingsGoal goal) {
    return _goals.upsert(goal);
  }

  @override
  Future<void> delete({required String plannerId, required String id}) async {
    final record = await _goals.get(id);
    final goal = record?.data;
    if (goal == null || goal.plannerId != plannerId) {
      return;
    }
    await _goals.delete(id);
  }
}
