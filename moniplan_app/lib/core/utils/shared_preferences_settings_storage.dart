// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:shared_preferences/shared_preferences.dart';

/// Интерфейс для хранения настроек
abstract class SettingsStorage {
  /// Сохраняет строку по ключу
  Future<void> saveString(String key, String value);

  /// Получает строку по ключу
  Future<String?> getString(String key);
}

/// Реализация хранилища настроек с использованием SharedPreferences
class SharedPreferencesSettingsStorage implements SettingsStorage {
  /// Экземпляр SharedPreferences
  SharedPreferences? _prefs;

  /// Конструктор
  SharedPreferencesSettingsStorage();

  /// Инициализирует SharedPreferences
  Future<void> _initPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  @override
  Future<String?> getString(String key) async {
    await _initPrefs();
    return _prefs!.getString(key);
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _initPrefs();
    await _prefs!.setString(key, value);
  }
}
