// filepath: /Users/nogipx/nogipx_vault/projects/apps/moniplan/moniplan_app/lib/features/monisync/bloc/monisync_event.dart

part of 'monisync_bloc.dart';

abstract class MonisyncEvent {}

/// Инициализация блока - получение репозиториев из DI
class MonisyncInitEvent extends MonisyncEvent {}

/// Экспорт в новом формате
class MonisyncExportNewEvent extends MonisyncEvent {
  final String password;
  MonisyncExportNewEvent({required this.password});
}

/// Импорт из нового формата
class MonisyncImportNewEvent extends MonisyncEvent {
  final String token;
  final String password;
  MonisyncImportNewEvent({required this.token, required this.password});
}

/// Чтение информации о бэкапе (новый формат)
class MonisyncReadNewBackupInfoEvent extends MonisyncEvent {
  final String token;
  final String? password;
  MonisyncReadNewBackupInfoEvent({required this.token, this.password});
}
