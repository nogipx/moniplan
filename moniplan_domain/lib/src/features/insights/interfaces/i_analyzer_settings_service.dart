// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/// Интерфейс для сервиса управления настройками анализаторов
abstract class IAnalyzerSettingsService {
  /// Получает список идентификаторов включенных анализаторов
  List<String> getEnabledAnalyzerIds();

  /// Включает анализатор
  void enableAnalyzer(String id);

  /// Выключает анализатор
  void disableAnalyzer(String id);

  /// Сохраняет настройки анализаторов
  Future<void> saveSettings();

  /// Загружает настройки анализаторов
  Future<void> loadSettings();
}

/// Интерфейс для хранения настроек
abstract class ISettingsStorage {
  /// Сохраняет строку по ключу
  Future<void> saveString(String key, String value);

  /// Получает строку по ключу
  Future<String?> getString(String key);
}
