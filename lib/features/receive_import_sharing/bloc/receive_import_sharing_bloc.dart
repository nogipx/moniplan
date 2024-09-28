import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

part 'state.dart';
part 'event.dart';

/// Handles receiving opening backup files. Passes files to business logic.
/// Because it depends on platform it could depend on library.
class ReceiveImportSharingBloc extends Bloc<ReceiveImportEvent, ReceiveImportState> {
  final AppLog _log;
  final IMonisyncRepo _monisyncRepo;

  ReceiveImportSharingBloc({
    required IMonisyncRepo monisyncRepo,
    AppLog? log,
  })  : _log = log ?? AppLog('ReceiveImportSharingBloc'),
        _monisyncRepo = monisyncRepo,
        super(ReceiveImportInitialState()) {
    on<ReceiveImportStartReceiveEvent>(_onStartReceive);
    on<ReceiveImportStopReceiveEvent>(_onStopReceive);
    on<ReceiveImportOnDataEvent>(_onData);
    on<ReceiveImportOnDecisionEvent>(_onDecision);
    on<ReceiveImportCheckIsActiveEvent>(_onCheckIsActive);
  }

  StreamSubscription? _intentStream;

  FutureOr<void> _onStartReceive(
    ReceiveImportStartReceiveEvent event,
    Emitter<ReceiveImportState> emit,
  ) async {
    if (event.shouldRestart) {
      _intentStream?.cancel();
    } else {
      _onCheckIsActive(ReceiveImportCheckIsActiveEvent(), emit);
      return;
    }

    _intentStream = ReceiveSharingIntent.instance.getMediaStream().listen((v) {
      _onData(ReceiveImportOnDataEvent(receivedValues: v), emit);
    });

    final inititalFiles = await ReceiveSharingIntent.instance.getInitialMedia();
    if (inititalFiles.isNotEmpty) {
      _onData(ReceiveImportOnDataEvent(receivedValues: inititalFiles), emit);
    }

    _onCheckIsActive(ReceiveImportCheckIsActiveEvent(), emit);
  }

  FutureOr<void> _onStopReceive(
    ReceiveImportStopReceiveEvent event,
    Emitter<ReceiveImportState> emit,
  ) {
    _intentStream?.cancel();
    _intentStream = null;

    emit(ReceiveImportActiveState(isActive: false));
  }

  FutureOr<void> _onData(
    ReceiveImportOnDataEvent event,
    Emitter<ReceiveImportState> emit,
  ) async {
    final backupInfos = <BackupInfo>[];
    for (final file in event.receivedValues) {
      try {
        if (!file.path.endsWith('.moniplan')) {
          continue;
        }

        final backupInfo = await _monisyncRepo.readBackupInfo(file.path);
        if (backupInfo != null) {
          backupInfos.add(backupInfo);
        }
      } on Object catch (error, trace) {
        _log.error('Failed to load backup info', error: error, trace: trace);
      }
    }

    emit(ReceiveImportDecisionState(toImportBackups: backupInfos));
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
      await _monisyncRepo.importDataFromFile(filePath: filePath);
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
}
