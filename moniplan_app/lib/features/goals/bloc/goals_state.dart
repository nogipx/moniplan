part of 'goals_cubit.dart';

class GoalsState extends Equatable {
  const GoalsState({this.goal, this.loading = false});

  const GoalsState.loading()
      : goal = null,
        loading = true;

  /// Единственная цель планера («оставить X к зарплате»), либо null.
  final SavingsGoal? goal;
  final bool loading;

  @override
  List<Object?> get props => [goal, loading];
}
