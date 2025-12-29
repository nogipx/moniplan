// filepath: /Users/nogipx/nogipx_vault/projects/apps/moniplan/moniplan_app/lib/features/monisync/bloc/monisync_state.dart

part of 'monisync_bloc.dart';

abstract class MonisyncState {}

class MonisyncInitialState extends MonisyncState {}

class MonisyncLoadingState extends MonisyncState {}

/// Состояния для нового формата
class MonisyncNewExportSuccessState extends MonisyncState {
  final String token;
  final List<int> bytes;
  final String fileName;
  MonisyncNewExportSuccessState({required this.token, required this.bytes, required this.fileName});
}

class MonisyncNdjsonExportSuccessState extends MonisyncState {
  final List<int> bytes;
  final String fileName;
  MonisyncNdjsonExportSuccessState({required this.bytes, required this.fileName});
}

class MonisyncNewBackupInfoState extends MonisyncState {
  final BackupInfo backupInfo;
  MonisyncNewBackupInfoState({required this.backupInfo});
}

/// Состояния для legacy формата
class MonisyncLegacyBackupInfoState extends MonisyncState {
  final LegacyBackupInfo backupInfo;
  MonisyncLegacyBackupInfoState({required this.backupInfo});
}

class MonisyncLegacyPasswordProtectionState extends MonisyncState {
  final bool isPasswordProtected;
  MonisyncLegacyPasswordProtectionState({required this.isPasswordProtected});
}

/// Общие состояния результата
class MonisyncImportResultState extends MonisyncState {
  final bool success;
  final String? message;
  final bool isLegacy;
  MonisyncImportResultState({required this.success, required this.isLegacy, this.message});
}

class MonisyncErrorState extends MonisyncState {
  final String message;
  final bool isLegacy;
  MonisyncErrorState({required this.message, required this.isLegacy});
}
