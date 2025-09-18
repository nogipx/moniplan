import 'package:equatable/equatable.dart';
import 'package:monishare/models.dart';

class MonishareInviteLocal extends Equatable {
  const MonishareInviteLocal({
    required this.inviteId,
    required this.createdAt,
    required this.state,
    required this.ownerHandshakeB64,
    this.expiresAt,
    this.joinerHandshakeB64,
    this.finalHandshakeB64,
    this.encryptedEnvelopeB64,
  });

  final String inviteId;
  final DateTime createdAt;
  final InviteState state;
  final DateTime? expiresAt;
  final String ownerHandshakeB64;
  final String? joinerHandshakeB64;
  final String? finalHandshakeB64;
  final String? encryptedEnvelopeB64;

  MonishareInviteLocal copyWith({
    InviteState? state,
    DateTime? expiresAt,
    String? ownerHandshakeB64,
    String? joinerHandshakeB64,
    String? finalHandshakeB64,
    String? encryptedEnvelopeB64,
  }) {
    return MonishareInviteLocal(
      inviteId: inviteId,
      createdAt: createdAt,
      state: state ?? this.state,
      expiresAt: expiresAt ?? this.expiresAt,
      ownerHandshakeB64: ownerHandshakeB64 ?? this.ownerHandshakeB64,
      joinerHandshakeB64: joinerHandshakeB64 ?? this.joinerHandshakeB64,
      finalHandshakeB64: finalHandshakeB64 ?? this.finalHandshakeB64,
      encryptedEnvelopeB64:
          encryptedEnvelopeB64 ?? this.encryptedEnvelopeB64,
    );
  }

  Map<String, dynamic> toJson() => {
        'inviteId': inviteId,
        'createdAt': createdAt.toIso8601String(),
        'state': state.name,
        'expiresAt': expiresAt?.toIso8601String(),
        'ownerHandshakeB64': ownerHandshakeB64,
        'joinerHandshakeB64': joinerHandshakeB64,
        'finalHandshakeB64': finalHandshakeB64,
        'encryptedEnvelopeB64': encryptedEnvelopeB64,
      };

  static MonishareInviteLocal fromJson(Map<String, dynamic> json) {
    return MonishareInviteLocal(
      inviteId: json['inviteId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      state: inviteStateFromJson(json['state'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      ownerHandshakeB64: json['ownerHandshakeB64'] as String,
      joinerHandshakeB64: json['joinerHandshakeB64'] as String?,
      finalHandshakeB64: json['finalHandshakeB64'] as String?,
      encryptedEnvelopeB64: json['encryptedEnvelopeB64'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        inviteId,
        createdAt,
        state,
        expiresAt,
        ownerHandshakeB64,
        joinerHandshakeB64,
        finalHandshakeB64,
        encryptedEnvelopeB64,
      ];
}
