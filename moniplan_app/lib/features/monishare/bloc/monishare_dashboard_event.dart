part of 'monishare_dashboard_bloc.dart';

abstract class MonishareDashboardEvent extends Equatable {
  const MonishareDashboardEvent();

  @override
  List<Object?> get props => const [];
}

class MonishareDashboardStarted extends MonishareDashboardEvent {
  const MonishareDashboardStarted();
}

class MonishareDashboardRefreshRequested extends MonishareDashboardEvent {
  const MonishareDashboardRefreshRequested();
}

class MonishareDashboardConnectionRequested extends MonishareDashboardEvent {
  const MonishareDashboardConnectionRequested();
}

class MonishareDashboardMessageCleared extends MonishareDashboardEvent {
  const MonishareDashboardMessageCleared();
}

class _MonishareDashboardStatusChanged extends MonishareDashboardEvent {
  const _MonishareDashboardStatusChanged({required this.isConnected});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}
