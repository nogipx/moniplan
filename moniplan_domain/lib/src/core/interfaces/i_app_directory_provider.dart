/// Интерфейс для доступа к директории приложения
abstract class IAppDirectoryProvider {
  /// Возвращает путь к директории приложения
  Future<String> getAppDirectoryPath();
}
