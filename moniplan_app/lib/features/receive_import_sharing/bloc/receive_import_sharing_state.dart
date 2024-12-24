part of 'receive_import_sharing_bloc.dart';

enum ReceiveImportResult {
  imported,
  fileNotFound,
  cancelled,
  error,
}

abstract class ReceiveImportState {}

class ReceiveImportInitialState implements ReceiveImportState {}

class ReceiveImportDecisionState implements ReceiveImportState {
  final List<BackupInfo> toImportBackups;

  ReceiveImportDecisionState({this.toImportBackups = const []});
}

class ReceiveImportResultState implements ReceiveImportState {
  final ReceiveImportResult result;

  ReceiveImportResultState({required this.result});
}

class ReceiveImportActiveState implements ReceiveImportState {
  final bool isActive;

  ReceiveImportActiveState({required this.isActive});
}
