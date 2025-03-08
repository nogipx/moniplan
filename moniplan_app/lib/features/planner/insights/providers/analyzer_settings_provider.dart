// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:moniplan_app/core/utils/shared_preferences_settings_storage.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import 'insight_generator_impl.dart';

/// Провайдер для управления настройками анализаторов
class AnalyzerSettingsProvider extends ChangeNotifier {
  /// Фабрика анализаторов
  final IAnalyzerFactory _analyzerFactory;

  /// Сервис настроек анализаторов
  final IAnalyzerSettingsService _settingsService;

  /// Список всех анализаторов
  List<AnalyzerDescriptor> _analyzers = [];

  /// Список идентификаторов включенных анализаторов
  List<String> _enabledAnalyzerIds = [];

  /// Флаг загрузки
  bool _isLoading = true;

  /// Конструктор
  AnalyzerSettingsProvider({
    IAnalyzerFactory? analyzerFactory,
    IAnalyzerSettingsService? settingsService,
  }) : _analyzerFactory = analyzerFactory ?? AnalyzerFactoryImpl(),
       _settingsService =
           settingsService ??
           AnalyzerSettingsService(
             analyzerFactory: analyzerFactory ?? AnalyzerFactoryImpl(),
             settingsStorage: SettingsStorageAdapter(SharedPreferencesSettingsStorage()),
           ) {
    _loadSettings();
  }

  /// Список всех анализаторов
  List<AnalyzerDescriptor> get analyzers => _analyzers;

  /// Флаг загрузки
  bool get isLoading => _isLoading;

  /// Проверяет, включен ли анализатор
  bool isAnalyzerEnabled(String id) {
    return _enabledAnalyzerIds.contains(id);
  }

  /// Загружает настройки анализаторов
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _settingsService.loadSettings();
      _enabledAnalyzerIds = _settingsService.getEnabledAnalyzerIds();
      _analyzers = _analyzerFactory.getAvailableAnalyzers();
    } catch (e) {
      debugPrint('Ошибка при загрузке настроек анализаторов: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Сохраняет настройки анализаторов
  Future<void> saveSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _settingsService.saveSettings();
    } catch (e) {
      debugPrint('Ошибка при сохранении настроек анализаторов: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Включает или выключает анализатор
  void toggleAnalyzer(String id, bool isEnabled) {
    if (isEnabled) {
      _settingsService.enableAnalyzer(id);
      _enabledAnalyzerIds.add(id);
    } else {
      _settingsService.disableAnalyzer(id);
      _enabledAnalyzerIds.remove(id);
    }

    notifyListeners();
  }

  /// Создает экземпляры включенных анализаторов
  List<IFinancialAnalyzer> createEnabledAnalyzers() {
    return _analyzerFactory.createAnalyzers(_enabledAnalyzerIds);
  }
}
