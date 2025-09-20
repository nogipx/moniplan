import 'dart:convert';

import 'package:moniplan_app/features/monishare/models/monishare_invite_local.dart';
import 'package:moniplan_app/features/monishare/models/monishare_space_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonishareLocalStore {
  static const _spacesKey = 'monishare_spaces_v1';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Map<String, dynamic>> _loadSpacesRaw() async {
    final prefs = await _preferences;
    final data = prefs.getString(_spacesKey);
    if (data == null || data.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on Object {
      // ignore parsing errors and fallback to empty map
    }
    return <String, dynamic>{};
  }

  Future<void> _persistSpaces(Map<String, dynamic> spaces) async {
    final prefs = await _preferences;
    await prefs.setString(_spacesKey, jsonEncode(spaces));
  }

  Future<MonishareSpaceInfo?> loadSpace(String plannerId) async {
    final raw = await _loadSpacesRaw();
    final value = raw[plannerId];
    if (value is Map<String, dynamic>) {
      return MonishareSpaceInfo.fromJson(value);
    }
    return null;
  }

  Future<List<MonishareSpaceInfo>> loadSpaces() async {
    final raw = await _loadSpacesRaw();
    final result = <MonishareSpaceInfo>[];
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        result.add(MonishareSpaceInfo.fromJson(value));
      }
    }
    return result;
  }

  Future<void> saveSpace(MonishareSpaceInfo info) async {
    final raw = await _loadSpacesRaw();
    raw[info.plannerId] = info.toJson();
    await _persistSpaces(raw);
  }

  Future<void> deleteSpace(String plannerId) async {
    final raw = await _loadSpacesRaw();
    raw.remove(plannerId);
    await _persistSpaces(raw);
  }

  String _invitesKey(String plannerId) => 'monishare_invites_$plannerId';

  Future<List<MonishareInviteLocal>> loadInvites(String plannerId) async {
    final prefs = await _preferences;
    final key = _invitesKey(plannerId);
    final data = prefs.getString(key);
    if (data == null || data.isEmpty) {
      return <MonishareInviteLocal>[];
    }

    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        final invites = decoded
            .whereType<Map<String, dynamic>>()
            .map(MonishareInviteLocal.fromJson)
            .toList();
        invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return invites;
      }
    } on Object {
      // ignore malformed payload and fallback to empty list
    }
    return <MonishareInviteLocal>[];
  }

  Future<void> upsertInvite(
    String plannerId,
    MonishareInviteLocal invite,
  ) async {
    final prefs = await _preferences;
    final key = _invitesKey(plannerId);
    final invites = await loadInvites(plannerId);
    final updated = <MonishareInviteLocal>[];
    var replaced = false;
    for (final existing in invites) {
      if (existing.inviteId == invite.inviteId) {
        updated.add(invite);
        replaced = true;
      } else {
        updated.add(existing);
      }
    }
    if (!replaced) {
      updated.add(invite);
    }
    await prefs.setString(
      key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removeInvite(String plannerId, String inviteId) async {
    final prefs = await _preferences;
    final key = _invitesKey(plannerId);
    final invites = await loadInvites(plannerId);
    final updated = invites.where((e) => e.inviteId != inviteId).toList();
    await prefs.setString(
      key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearInvites(String plannerId) async {
    final prefs = await _preferences;
    await prefs.remove(_invitesKey(plannerId));
  }
}
