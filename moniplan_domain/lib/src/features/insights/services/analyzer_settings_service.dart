// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import '../interfaces/i_analyzer_factory.dart';
import '../interfaces/i_analyzer_settings_service.dart';
import '../models/analyzer_descriptor.dart';

/// Реализация сервиса управления настройками анализаторов
class AnalyzerSettingsService implements IAnalyzerSettingsService {
  /// Ключ для хранения настроек анализаторов
  static const _settingsKey = 'analyzer_settings';

  /// Фабрика анализаторов
  final IAnalyzerFactory _analyzerFactory;

  /// Список идентификаторов включенных анализаторов
  final List<String> _enabledAnalyzerIds = [];

  /// Интерфейс для хранения настроек
  final ISettingsStorage _settingsStorage;

  /// Конструктор
  AnalyzerSettingsService({
    required IAnalyzerFactory analyzerFactory,
    required ISettingsStorage settingsStorage,
  }) : _analyzerFactory = analyzerFactory,
       _settingsStorage = settingsStorage {
    // По умолчанию включаем все анализаторы
    _enabledAnalyzerIds.addAll(_analyzerFactory.getAvailableAnalyzers().map((a) => a.id));
  }

  @override
  List<String> getEnabledAnalyzerIds() {
    return List.of(_enabledAnalyzerIds);
  }

  @override
  void enableAnalyzer(String id) {
    if (!_enabledAnalyzerIds.contains(id)) {
      _enabledAnalyzerIds.add(id);
    }
  }

  @override
  void disableAnalyzer(String id) {
    _enabledAnalyzerIds.remove(id);
  }

  @override
  Future<void> saveSettings() async {
    final settings = {'enabledAnalyzerIds': _enabledAnalyzerIds};

    await _settingsStorage.saveString(_settingsKey, jsonEncode(settings));
  }

  @override
  Future<void> loadSettings() async {
    final settingsJson = await _settingsStorage.getString(_settingsKey);

    if (settingsJson != null) {
      try {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;

        // Очищаем текущий список
        _enabledAnalyzerIds.clear();

        // Загружаем идентификаторы включенных анализаторов
        final enabledIds = settings['enabledAnalyzerIds'] as List<dynamic>;
        _enabledAnalyzerIds.addAll(enabledIds.cast<String>());
      } catch (e) {
        print('Ошибка при загрузке настроек анализаторов: $e');

        // В случае ошибки включаем все анализаторы
        _enabledAnalyzerIds.clear();
        _enabledAnalyzerIds.addAll(_analyzerFactory.getAvailableAnalyzers().map((a) => a.id));
      }
    }
  }
}
