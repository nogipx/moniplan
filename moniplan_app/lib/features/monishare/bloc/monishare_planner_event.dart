part of 'monishare_planner_bloc.dart';

abstract class MonisharePlannerEvent extends Equatable {
  const MonisharePlannerEvent();

  @override
  List<Object?> get props => const [];
}

class MonisharePlannerStarted extends MonisharePlannerEvent {
  const MonisharePlannerStarted();
}

class MonisharePlannerEnsureSpaceRequested extends MonisharePlannerEvent {
  const MonisharePlannerEnsureSpaceRequested();
}

class MonisharePlannerRefreshOperationsRequested extends MonisharePlannerEvent {
  const MonisharePlannerRefreshOperationsRequested({this.space});

  final MonishareSpaceInfo? space;

  @override
  List<Object?> get props => [space];
}

class MonisharePlannerAppendSnapshotRequested extends MonisharePlannerEvent {
  const MonisharePlannerAppendSnapshotRequested();
}

class MonisharePlannerCreateInviteRequested extends MonisharePlannerEvent {
  const MonisharePlannerCreateInviteRequested();
}

class MonisharePlannerRefreshInvitesRequested extends MonisharePlannerEvent {
  const MonisharePlannerRefreshInvitesRequested();
}

class MonisharePlannerFinalizeInviteRequested extends MonisharePlannerEvent {
  const MonisharePlannerFinalizeInviteRequested({required this.invite});

  final MonishareInviteLocal invite;

  @override
  List<Object?> get props => [invite];
}

class MonisharePlannerSubscriptionToggled extends MonisharePlannerEvent {
  const MonisharePlannerSubscriptionToggled({required this.subscribe});

  final bool subscribe;

  @override
  List<Object?> get props => [subscribe];
}

class MonisharePlannerRemoveSpaceRequested extends MonisharePlannerEvent {
  const MonisharePlannerRemoveSpaceRequested();
}

class MonisharePlannerJoinerInviteFetchRequested extends MonisharePlannerEvent {
  const MonisharePlannerJoinerInviteFetchRequested({required this.inviteId});

  final String inviteId;

  @override
  List<Object?> get props => [inviteId];
}

class MonisharePlannerJoinerRespondRequested extends MonisharePlannerEvent {
  const MonisharePlannerJoinerRespondRequested();
}

class MonisharePlannerJoinerRefreshRequested extends MonisharePlannerEvent {
  const MonisharePlannerJoinerRefreshRequested();
}

class MonisharePlannerApplyEnvelopeRequested extends MonisharePlannerEvent {
  const MonisharePlannerApplyEnvelopeRequested();
}

class MonisharePlannerMessageCleared extends MonisharePlannerEvent {
  const MonisharePlannerMessageCleared();
}

class _MonisharePlannerNotificationReceived extends MonisharePlannerEvent {
  const _MonisharePlannerNotificationReceived({required this.notification});

  final OpsNotification notification;

  @override
  List<Object?> get props => [notification];
}
