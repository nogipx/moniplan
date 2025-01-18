// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

part of 'receive_import_sharing_bloc.dart';

abstract class ReceiveImportEvent {}

class ReceiveImportStartReceiveEvent implements ReceiveImportEvent {
  final bool shouldRestart;

  ReceiveImportStartReceiveEvent({
    this.shouldRestart = false,
  });
}

class ReceiveImportStopReceiveEvent implements ReceiveImportEvent {}

class ReceiveImportCheckIsActiveEvent implements ReceiveImportEvent {}

class ReceiveImportOnDataEvent implements ReceiveImportEvent {
  final List<SharedMediaFile> receivedValues;

  ReceiveImportOnDataEvent({this.receivedValues = const []});
}

class ReceiveImportOnDecisionEvent implements ReceiveImportEvent {
  final BackupInfo? acceptedBackup;
  final bool shouldImport;

  /// TODO(nogipx): do think about partial import instead of fully replace database.

  ReceiveImportOnDecisionEvent({
    required this.shouldImport,
    this.acceptedBackup,
  });
}
