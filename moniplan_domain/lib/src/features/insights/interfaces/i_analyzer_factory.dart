// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import '../_index.dart';

/// Интерфейс фабрики анализаторов
abstract class IAnalyzerFactory {
  /// Инициализирует анализаторы
  void initAnalyzersData(IFinancialSource source);

  /// Получает список всех доступных анализаторов с их описаниями
  List<AnalyzerDescriptor> getAvailableAnalyzers();

  /// Получает список анализаторов по типу
  List<AnalyzerDescriptor> getAnalyzersByType(AnalyzerType type);

  /// Получает список анализаторов по тегам
  List<AnalyzerDescriptor> getAnalyzersByTags(List<String> tags);

  /// Получает список анализаторов по идентификаторам
  List<AnalyzerDescriptor> getAnalyzersByIds(List<String> ids);

  /// Получает анализатор по его идентификатору
  IFinancialAnalyzer createAnalyzer(String id);

  /// Создает набор анализаторов по их идентификаторам
  List<IFinancialAnalyzer> createAnalyzers(List<String> ids);

  /// Создает набор анализаторов по типу
  List<IFinancialAnalyzer> createAnalyzersByType(AnalyzerType type);

  /// Создает набор анализаторов по тегам
  List<IFinancialAnalyzer> createAnalyzersByTags(List<String> tags);

  /// Создает все доступные анализаторы
  List<IFinancialAnalyzer> createAllAnalyzers();

  /// Регистрирует настраиваемые анализаторы
  void registerCustomAnalyzers(Map<String, IFinancialAnalyzer> analyzers);
}
