import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/goals/models/savings_goal.dart';
import 'package:moniplan_app/features/goals/repo/i_savings_goals_repo.dart';

part 'goals_state.dart';

/// Одна цель на планер: «оставить X к зарплате». Хранится с id == plannerId.
class GoalsCubit extends Cubit<GoalsState> {
  GoalsCubit({required ISavingsGoalsRepo repo, required this.plannerId})
    : _repo = repo,
      super(const GoalsState.loading()) {
    load();
  }

  final ISavingsGoalsRepo _repo;
  final String plannerId;

  Future<void> load() async {
    final goals = await _repo.listByPlanner(plannerId);
    emit(GoalsState(goal: goals.isEmpty ? null : goals.first));
  }

  Future<void> save(SavingsGoal goal) async {
    final id = goal.id.isEmpty ? plannerId : goal.id;
    await _repo.upsert(goal.copyWith(id: id, plannerId: plannerId));
    await load();
  }

  Future<void> remove() async {
    final current = state.goal;
    if (current == null) {
      return;
    }
    await _repo.delete(plannerId: plannerId, id: current.id);
    await load();
  }
}
