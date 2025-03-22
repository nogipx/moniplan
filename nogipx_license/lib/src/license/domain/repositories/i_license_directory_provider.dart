/// Интерфейс для доступа к директории приложения
abstract class ILicenseDirectoryProvider {
  /// Возвращает путь к директории приложения
  Future<String> getLicenseDirectoryPath();
}
