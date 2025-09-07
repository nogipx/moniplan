// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:moniplan_app/domain/lib/moniplan_domain.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

part 'receive_import_sharing_event.dart';
part 'receive_import_sharing_state.dart';

/// Handles receiving opening backup files. Passes files to business logic.
/// Because it depends on platform it could depend on library.
class ReceiveImportSharingBloc extends Bloc<ReceiveImportEvent, ReceiveImportState> {
  final _log = AppLog('ReceiveImportSharingBloc');
  final IAppDi appDi;
  IMonisyncRepo? _monisyncRepo;
  IMoniplanLicenseRepo? _licenseRepo;

  ReceiveImportSharingBloc({required this.appDi, AppLog? log})
    : super(ReceiveImportInitialState()) {
    on<ReceiveImportStartReceiveEvent>(_onStartReceive);
    on<ReceiveImportStopReceiveEvent>(_onStopReceive);
    on<ReceiveImportOnDataEvent>(_onData);
    on<ReceiveImportOnDecisionEvent>(_onDecision);
    on<ReceiveImportOnLicenseDataEvent>(_onLicenseData);
    on<ReceiveImportCheckIsActiveEvent>(_onCheckIsActive);
  }

  StreamSubscription? _intentStream;

  FutureOr<void> _onStartReceive(
    ReceiveImportStartReceiveEvent event,
    Emitter<ReceiveImportState> emit,
  ) async {
    _monisyncRepo = await appDi.getMonisyncRepo();
    _licenseRepo = appDi.getLicenseRepo();

    if (event.shouldRestart) {
      _intentStream?.cancel();
    } else if (_intentStream != null) {
      add(ReceiveImportCheckIsActiveEvent());
      return;
    }

    _intentStream = ReceiveSharingIntent.instance.getMediaStream().listen((v) async {
      add(ReceiveImportOnDataEvent(receivedValues: v));
    });

    final inititalFiles = await ReceiveSharingIntent.instance.getInitialMedia();
    add(ReceiveImportOnDataEvent(receivedValues: inititalFiles));

    add(ReceiveImportCheckIsActiveEvent());
  }

  FutureOr<void> _onStopReceive(
    ReceiveImportStopReceiveEvent event,
    Emitter<ReceiveImportState> emit,
  ) {
    _intentStream?.cancel();
    _intentStream = null;
    _monisyncRepo = null;
    _licenseRepo = null;

    emit(ReceiveImportActiveState(isActive: false));
  }

  Future<void> _onData(ReceiveImportOnDataEvent event, Emitter<ReceiveImportState> emit) async {
    if (event.receivedValues.isEmpty) {
      return;
    }
    ReceiveSharingIntent.instance.reset();

    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    final backupInfos = <BackupInfo>[];
    final licenseFiles = <SharedMediaFile>[];

    for (final file in event.receivedValues) {
      try {
        if (file.path.endsWith('.moniplan')) {
          final backupInfo = await _monisyncRepo?.readBackupInfo(filePath: file.path);
          if (backupInfo != null) {
            backupInfos.add(backupInfo);
          }
        } else if (file.path.endsWith('.licensify') || file.path.endsWith('.mlr')) {
          licenseFiles.add(file);
        }
      } on Object catch (error, trace) {
        _log.error('Failed to process file', error: error, trace: trace);
      }
    }

    if (backupInfos.isNotEmpty) {
      emit(ReceiveImportDecisionState(toImportBackups: backupInfos));
    } else if (licenseFiles.isNotEmpty) {
      add(ReceiveImportOnLicenseDataEvent(licenseFiles: licenseFiles));
    }
  }

  Future<void> _onLicenseData(
    ReceiveImportOnLicenseDataEvent event,
    Emitter<ReceiveImportState> emit,
  ) async {
    if (event.licenseFiles.isEmpty || _licenseRepo == null) {
      return;
    }

    try {
      final licenseFile = event.licenseFiles.first;
      emit(ReceiveImportLicenseState(licenseFile: licenseFile));
    } catch (e, trace) {
      _log.error('Failed to process license file', error: e, trace: trace);
      emit(ReceiveImportResultState(result: ReceiveImportResult.error));
    }
  }

  FutureOr<void> _onDecision(
    ReceiveImportOnDecisionEvent event,
    Emitter<ReceiveImportState> emit,
  ) async {
    final shouldImport = event.shouldImport;
    if (!shouldImport) {
      emit(ReceiveImportResultState(result: ReceiveImportResult.cancelled));
      return;
    }

    final filePath = event.acceptedBackup?.file.path;
    if (filePath == null || filePath.isEmpty) {
      emit(ReceiveImportResultState(result: ReceiveImportResult.fileNotFound));
      return;
    }

    try {
      await _monisyncRepo?.importDataFromFile(filePath: filePath, password: event.password);
      _log.business('Succesfull import db');
      emit(ReceiveImportResultState(result: ReceiveImportResult.imported));
    } on Object catch (error, trace) {
      emit(ReceiveImportResultState(result: ReceiveImportResult.error));
      _log.error('Failed to import db', error: error, trace: trace);
    }
  }

  FutureOr<void> _onCheckIsActive(
    ReceiveImportCheckIsActiveEvent event,
    Emitter<ReceiveImportState> emit,
  ) {
    emit(ReceiveImportActiveState(isActive: _intentStream != null));
  }

  @override
  Future<void> close() async {
    super.close();
    _intentStream?.cancel();
    _intentStream = null;
  }
}
