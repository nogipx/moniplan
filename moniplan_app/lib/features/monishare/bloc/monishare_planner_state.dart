part of 'monishare_planner_bloc.dart';

class MonisharePlannerState extends Equatable {
  const MonisharePlannerState({
    this.isLoading = false,
    this.ownerBusy = false,
    this.joinerBusy = false,
    this.isSubscribed = false,
    this.planner,
    this.space,
    this.operations = const [],
    this.invites = const [],
    this.joinerInvite,
    this.joinerResponseB64,
    this.lastNotification,
    this.message,
    this.errorMessage,
  });

  final bool isLoading;
  final bool ownerBusy;
  final bool joinerBusy;
  final bool isSubscribed;
  final Planner? planner;
  final MonishareSpaceInfo? space;
  final List<OperationRecord> operations;
  final List<MonishareInviteLocal> invites;
  final Invite? joinerInvite;
  final String? joinerResponseB64;
  final OpsNotification? lastNotification;
  final String? message;
  final String? errorMessage;

  static const _noUpdate = Object();

  MonisharePlannerState copyWith({
    bool? isLoading,
    bool? ownerBusy,
    bool? joinerBusy,
    bool? isSubscribed,
    Object? planner = _noUpdate,
    Object? space = _noUpdate,
    List<OperationRecord>? operations,
    List<MonishareInviteLocal>? invites,
    Object? joinerInvite = _noUpdate,
    Object? joinerResponseB64 = _noUpdate,
    Object? lastNotification = _noUpdate,
    Object? message = _noUpdate,
    Object? errorMessage = _noUpdate,
    bool clearMessages = false,
  }) {
    final nextOperations = operations != null
        ? List<OperationRecord>.unmodifiable(operations)
        : this.operations;
    final nextInvites = invites != null
        ? List<MonishareInviteLocal>.unmodifiable(invites)
        : this.invites;
    final nextPlanner =
        identical(planner, _noUpdate) ? this.planner : planner as Planner?;
    final nextSpace =
        identical(space, _noUpdate) ? this.space : space as MonishareSpaceInfo?;
    final nextJoinerInvite = identical(joinerInvite, _noUpdate)
        ? this.joinerInvite
        : joinerInvite as Invite?;
    final nextJoinerResponse = identical(joinerResponseB64, _noUpdate)
        ? this.joinerResponseB64
        : joinerResponseB64 as String?;
    final nextLastNotification = identical(lastNotification, _noUpdate)
        ? this.lastNotification
        : lastNotification as OpsNotification?;
    return MonisharePlannerState(
      isLoading: isLoading ?? this.isLoading,
      ownerBusy: ownerBusy ?? this.ownerBusy,
      joinerBusy: joinerBusy ?? this.joinerBusy,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      planner: nextPlanner,
      space: nextSpace,
      operations: nextOperations,
      invites: nextInvites,
      joinerInvite: nextJoinerInvite,
      joinerResponseB64: nextJoinerResponse,
      lastNotification: nextLastNotification,
      message: clearMessages
          ? null
          : identical(message, _noUpdate)
              ? this.message
              : message as String?,
      errorMessage: clearMessages
          ? null
          : identical(errorMessage, _noUpdate)
              ? this.errorMessage
              : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        ownerBusy,
        joinerBusy,
        isSubscribed,
        planner,
        space,
        operations,
        invites,
        joinerInvite,
        joinerResponseB64,
        lastNotification,
        message,
        errorMessage,
      ];
}
