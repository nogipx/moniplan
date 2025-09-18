import 'package:equatable/equatable.dart';

class MonishareSpaceInfo extends Equatable {
  const MonishareSpaceInfo({
    required this.plannerId,
    required this.plannerSpaceId,
    required this.actorPseudoId,
    required this.spaceKeyB64,
    this.serverUri,
    this.lastSyncedOpIdx = 0,
  });

  final String plannerId;
  final String plannerSpaceId;
  final String actorPseudoId;
  final String spaceKeyB64;
  final String? serverUri;
  final int lastSyncedOpIdx;

  MonishareSpaceInfo copyWith({
    String? plannerSpaceId,
    String? actorPseudoId,
    String? spaceKeyB64,
    String? serverUri,
    int? lastSyncedOpIdx,
  }) {
    return MonishareSpaceInfo(
      plannerId: plannerId,
      plannerSpaceId: plannerSpaceId ?? this.plannerSpaceId,
      actorPseudoId: actorPseudoId ?? this.actorPseudoId,
      spaceKeyB64: spaceKeyB64 ?? this.spaceKeyB64,
      serverUri: serverUri ?? this.serverUri,
      lastSyncedOpIdx: lastSyncedOpIdx ?? this.lastSyncedOpIdx,
    );
  }

  Map<String, dynamic> toJson() => {
        'plannerId': plannerId,
        'plannerSpaceId': plannerSpaceId,
        'actorPseudoId': actorPseudoId,
        'spaceKeyB64': spaceKeyB64,
        'serverUri': serverUri,
        'lastSyncedOpIdx': lastSyncedOpIdx,
      };

  static MonishareSpaceInfo fromJson(Map<String, dynamic> json) {
    return MonishareSpaceInfo(
      plannerId: json['plannerId'] as String,
      plannerSpaceId: json['plannerSpaceId'] as String,
      actorPseudoId: json['actorPseudoId'] as String,
      spaceKeyB64: json['spaceKeyB64'] as String,
      serverUri: json['serverUri'] as String?,
      lastSyncedOpIdx: (json['lastSyncedOpIdx'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        plannerId,
        plannerSpaceId,
        actorPseudoId,
        spaceKeyB64,
        serverUri,
        lastSyncedOpIdx,
      ];
}
