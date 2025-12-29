// filepath: /Users/nogipx/nogipx_vault/projects/apps/moniplan/moniplan_app/lib/features/monisync/bloc/monisync_bloc.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/features/monisync/legacy_monisync/repo/i_manual_monisync_repo.dart';
import 'package:moniplan_app/features/monisync/legacy_monisync/repo/password_only_monisync_repo_impl.dart';
import 'package:moniplan_app/features/monisync/models/backup_info.dart';
import 'package:moniplan_app/features/monisync/repo/i_manual_monisync_repo.dart';
import 'package:moniplan_app/features/monisync/services/ndjson_export_service.dart';
import 'package:rpc_dart/logger.dart';

part 'monisync_event.dart';
part 'monisync_state.dart';

const _ndjsonFileDateFormat = 'yyyyMMdd_HHmmss';

class MonisyncBloc extends Bloc<MonisyncEvent, MonisyncState> {
  final IAppDi appDi;
  final _log = RpcLogger('MonisyncBloc');

  IMonisyncRepo? _newRepo;
  LegacyIMonisyncRepo? _legacyRepo;

  MonisyncBloc({required this.appDi}) : super(MonisyncInitialState()) {
    on<MonisyncInitEvent>(_onInit);
    on<MonisyncExportNewEvent>(_onExportNew);
    on<MonisyncExportNdjsonEvent>(_onExportNdjson);
    on<MonisyncImportNewEvent>(_onImportNew);
    on<MonisyncReadNewBackupInfoEvent>(_onReadNewBackupInfo);
    on<MonisyncLegacyImportEvent>(_onLegacyImport);
    on<MonisyncReadLegacyBackupInfoEvent>(_onReadLegacyBackupInfo);
    on<MonisyncCheckLegacyPasswordProtectionEvent>(_onCheckLegacyPasswordProtection);
  }

  /// Создание Legacy репозитория для работы только с паролями пользователя
  /// Исключает поддержку стандартного ключа приложения для повышения безопасности
  LegacyIMonisyncRepo _createLegacyRepo() {
    // Используем новую реализацию, которая работает только с паролями
    return PasswordOnlyLegacyMonisyncRepoImpl(appDb: appDi.getDb());
  }

  FutureOr<void> _onInit(MonisyncInitEvent event, Emitter<MonisyncState> emit) async {
    try {
      _newRepo = await appDi.getMonisyncRepo();
      // Создаем legacy репозиторий локально
      _legacyRepo = _createLegacyRepo();
      emit(MonisyncInitialState());
    } on Object catch (e, s) {
      _log.error('Failed to init repos', error: e, stackTrace: s);
      emit(MonisyncErrorState(message: 'Не удалось инициализировать репозитории', isLegacy: false));
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
      emit(MonisyncErrorState(message: 'Ошибка при экспорте данных', isLegacy: false));
    }
  }

  Future<void> _onExportNdjson(
    MonisyncExportNdjsonEvent event,
    Emitter<MonisyncState> emit,
  ) async {
    emit(MonisyncLoadingState());

    try {
      final exporter = NdjsonExportService(appDb: appDi.getDb() as AppDb);
      final result = await exporter.export();

      final now = DateTime.now();
      final fileName = 'moniplan_export_${DateFormat(_ndjsonFileDateFormat).format(now)}.ndjson';

      emit(
        MonisyncNdjsonExportSuccessState(
          bytes: utf8.encode(result.content),
          fileName: fileName,
        ),
      );
    } on Object catch (e, s) {
      _log.error('NDJSON export failed', error: e, stackTrace: s);
      emit(MonisyncErrorState(message: 'Ошибка при экспорте данных', isLegacy: false));
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
          isLegacy: false,
        ),
      );
    } on Object catch (e, s) {
      _log.error('Import failed', error: e, stackTrace: s);
      emit(
        MonisyncImportResultState(
          success: false,
          message: 'Не удалось импортировать данные',
          isLegacy: false,
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
            isLegacy: false,
          ),
        );
        return;
      }

      emit(MonisyncNewBackupInfoState(backupInfo: info));
    } on Object catch (e, s) {
      _log.error('Read backup info failed', error: e, stackTrace: s);
      emit(MonisyncErrorState(message: 'Ошибка при чтении информации о бэкапе', isLegacy: false));
    }
  }

  Future<void> _onLegacyImport(MonisyncLegacyImportEvent event, Emitter<MonisyncState> emit) async {
    emit(MonisyncLoadingState());

    try {
      // Создаем или используем существующий legacy репозиторий
      final repo = _legacyRepo ??= _createLegacyRepo();

      await repo.importDataFromFile(filePath: event.filePath, password: event.password);

      emit(
        MonisyncImportResultState(
          success: true,
          message: 'Legacy данные успешно импортированы',
          isLegacy: true,
        ),
      );
    } on Object catch (e, s) {
      _log.error('Legacy import failed', error: e, stackTrace: s);
      emit(
        MonisyncImportResultState(
          success: false,
          message: 'Не удалось импортировать legacy данные',
          isLegacy: true,
        ),
      );
    }
  }

  Future<void> _onReadLegacyBackupInfo(
    MonisyncReadLegacyBackupInfoEvent event,
    Emitter<MonisyncState> emit,
  ) async {
    emit(MonisyncLoadingState());

    try {
      // Создаем или используем существующий legacy репозиторий
      final repo = _legacyRepo ??= _createLegacyRepo();

      final info = await repo.readBackupInfo(filePath: event.filePath, password: event.password);

      if (info == null) {
        emit(
          MonisyncErrorState(
            message: 'Неверный формат legacy бэкапа или неправильный пароль',
            isLegacy: true,
          ),
        );
        return;
      }

      emit(MonisyncLegacyBackupInfoState(backupInfo: info));
    } on Object catch (e, s) {
      _log.error('Read legacy backup info failed', error: e, stackTrace: s);
      emit(
        MonisyncErrorState(message: 'Ошибка при чтении информации о legacy бэкапе', isLegacy: true),
      );
    }
  }

  Future<void> _onCheckLegacyPasswordProtection(
    MonisyncCheckLegacyPasswordProtectionEvent event,
    Emitter<MonisyncState> emit,
  ) async {
    emit(MonisyncLoadingState());

    try {
      // Создаем или используем существующий legacy репозиторий
      final repo = _legacyRepo ??= _createLegacyRepo();

      final isProtected = await repo.isFilePasswordProtected(event.filePath);
      emit(MonisyncLegacyPasswordProtectionState(isPasswordProtected: isProtected));
    } on Object catch (e, s) {
      _log.error('Check legacy password protection failed', error: e, stackTrace: s);
      emit(
        MonisyncErrorState(
          message: 'Ошибка при проверке защиты паролем legacy бэкапа',
          isLegacy: true,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}
