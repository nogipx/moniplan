part of 'planners_list_bloc.dart';

class PlannersListState extends Equatable {
  const PlannersListState({
    this.planners = const [],
    this.currentPlannerId,
    this.loading = false,
  });

  final List<Planner> planners;
  final String? currentPlannerId;
  final bool loading;

  PlannersListState copyWith({
    List<Planner>? planners,
    String? currentPlannerId,
    bool? loading,
  }) {
    return PlannersListState(
      planners: planners ?? this.planners,
      currentPlannerId: currentPlannerId ?? this.currentPlannerId,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [planners, currentPlannerId, loading];
}
