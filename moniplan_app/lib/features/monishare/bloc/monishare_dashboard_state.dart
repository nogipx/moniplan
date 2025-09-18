part of 'monishare_dashboard_bloc.dart';

class MonishareDashboardState extends Equatable {
  const MonishareDashboardState({
    required this.isLoading,
    required this.isConnecting,
    required this.isConnected,
    required this.planners,
    required this.spaces,
    this.message,
    this.errorMessage,
  });

  factory MonishareDashboardState.initial({required bool isConnected}) {
    return MonishareDashboardState(
      isLoading: false,
      isConnecting: false,
      isConnected: isConnected,
      planners: const [],
      spaces: const {},
    );
  }

  final bool isLoading;
  final bool isConnecting;
  final bool isConnected;
  final List<Planner> planners;
  final Map<String, MonishareSpaceInfo> spaces;
  final String? message;
  final String? errorMessage;

  static const _noUpdate = Object();

  MonishareDashboardState copyWith({
    bool? isLoading,
    bool? isConnecting,
    bool? isConnected,
    List<Planner>? planners,
    Map<String, MonishareSpaceInfo>? spaces,
    Object? message = _noUpdate,
    Object? errorMessage = _noUpdate,
  }) {
    final nextPlanners =
        planners != null ? List<Planner>.unmodifiable(planners) : this.planners;
    final nextSpaces = spaces != null
        ? Map<String, MonishareSpaceInfo>.unmodifiable(spaces)
        : this.spaces;
    return MonishareDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      planners: nextPlanners,
      spaces: nextSpaces,
      message: identical(message, _noUpdate) ? this.message : message as String?,
      errorMessage:
          identical(errorMessage, _noUpdate) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isConnecting,
        isConnected,
        planners,
        spaces,
        message,
        errorMessage,
      ];
}
