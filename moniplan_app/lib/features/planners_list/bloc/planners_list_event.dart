part of 'planners_list_bloc.dart';

sealed class PlannersListEvent extends Equatable {
  const PlannersListEvent();

  @override
  List<Object?> get props => [];
}

class PlannersListLoad extends PlannersListEvent {
  const PlannersListLoad();
}

class PlannersListAdd extends PlannersListEvent {
  const PlannersListAdd(this.planner);
  final Planner planner;

  @override
  List<Object?> get props => [planner];
}

class PlannersListUpdate extends PlannersListEvent {
  const PlannersListUpdate(this.planner);
  final Planner planner;

  @override
  List<Object?> get props => [planner];
}

class PlannersListDelete extends PlannersListEvent {
  const PlannersListDelete(this.plannerId);
  final String plannerId;

  @override
  List<Object?> get props => [plannerId];
}

class PlannersListToggleCurrent extends PlannersListEvent {
  const PlannersListToggleCurrent(this.planner);
  final Planner planner;

  @override
  List<Object?> get props => [planner];
}
