// filepath: /Users/nogipx/nogipx_vault/projects/apps/moniplan/moniplan_app/lib/features/monisync/bloc/monisync_bloc.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/features/monisync/models/backup_info.dart';
import 'package:moniplan_app/features/monisync/repo/i_manual_monisync_repo.dart';
import 'package:rpc_dart/logger.dart';

part 'monisync_event.dart';
part 'monisync_state.dart';

class MonisyncBloc extends Bloc<MonisyncEvent, MonisyncState> {
  final IAppDi appDi;
  final _log = RpcLogger('MonisyncBloc');

  IMonisyncRepo? _newRepo;

  MonisyncBloc({required this.appDi}) : super(MonisyncInitialState()) {
    on<MonisyncInitEvent>(_onInit);
    on<MonisyncExportNewEvent>(_onExportNew);
    on<MonisyncImportNewEvent>(_onImportNew);
    on<MonisyncReadNewBackupInfoEvent>(_onReadNewBackupInfo);
  }

  FutureOr<void> _onInit(MonisyncInitEvent event, Emitter<MonisyncState> emit) async {
    try {
      _newRepo = await appDi.getMonisyncRepo();
      emit(MonisyncInitialState());
    } on Object catch (e, s) {
      _log.error('Failed to init repos', error: e, stackTrace: s);
      emit(MonisyncErrorState(message: 'Не удалось инициализировать репозитории'));
    }
  }

  Future<void> _onExportNew(MonisyncExportNewEvent event, Emitter<MonisyncState> emit) async {
    emit(MonisyncLoadingState());

    try {
      final repo = _newRepo ?? await appDi.getMonisyncRepo();
      _newRepo = repo;

      final now = DateTime.now();
      final token = await repo.exportData(now: now, password: event.password);

      final bytes = utf8.encode(token).toList();
      final fileName = repo.createBackupFileName(now);

      emit(MonisyncNewExportSuccessState(token: token, bytes: bytes, fileName: fileName));
    } on Object catch (e, s) {
      _log.error('Export failed', error: e, stackTrace: s);
      emit(MonisyncErrorState(message: 'Ошибка при экспорте данных'));
    }
  }

  Future<void> _onImportNew(MonisyncImportNewEvent event, Emitter<MonisyncState> emit) async {
    emit(MonisyncLoadingState());

    try {
      final repo = _newRepo ?? await appDi.getMonisyncRepo();
      _newRepo = repo;

      await repo.importData(token: event.token, password: event.password);
      emit(
        MonisyncImportResultState(
          success: true,
          message: 'Данные успешно импортированы',
        ),
      );
    } on Object catch (e, s) {
      _log.error('Import failed', error: e, stackTrace: s);
      emit(
        MonisyncImportResultState(
          success: false,
          message: 'Не удалось импортировать данные',
        ),
      );
    }
  }

  Future<void> _onReadNewBackupInfo(
    MonisyncReadNewBackupInfoEvent event,
    Emitter<MonisyncState> emit,
  ) async {
    emit(MonisyncLoadingState());

    try {
      final repo = _newRepo ?? await appDi.getMonisyncRepo();
      _newRepo = repo;

      final info = await repo.readBackupInfo(token: event.token, password: event.password);

      if (info == null) {
        emit(
          MonisyncErrorState(
            message: 'Неверный формат бэкапа или неправильный пароль',
          ),
        );
        return;
      }

      emit(MonisyncNewBackupInfoState(backupInfo: info));
    } on Object catch (e, s) {
      _log.error('Read backup info failed', error: e, stackTrace: s);
      emit(MonisyncErrorState(message: 'Ошибка при чтении информации о бэкапе'));
    }
  }
}
