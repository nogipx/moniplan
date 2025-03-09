// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';
import '../utils/payment_extraction_service.dart';

/// Реализация фабрики анализаторов
class AnalyzerFactoryImpl implements IAnalyzerFactory {
  /// Список всех доступных анализаторов с их описаниями
  final List<AnalyzerDescriptor> _availableAnalyzers = [];

  /// Фабричные функции для создания экземпляров анализаторов
  final Map<String, IFinancialAnalyzer Function()> _analyzerFactories = {};

  /// Инициализирует список доступных анализаторов
  @override
  void initAnalyzersData(IFinancialSource source, ICategoryPredictor categorizer) {
    _availableAnalyzers.clear();
    _analyzerFactories.clear();

    // Регистрируем стандартные анализаторы

    // Ретроспективные анализаторы
    _registerAnalyzer(
      id: 'financial_ratio_analyzer',
      name: 'Анализатор финансовых коэффициентов',
      description:
          'Рассчитывает ключевые финансовые показатели и сравнивает с рекомендуемыми значениями',
      type: AnalyzerType.retrospective,
      order: 3,
      tags: ['ratio', 'metrics', 'advanced', 'retrospective'],
      factory: () => FinancialRatioAnalyzer(source),
    );

    _registerAnalyzer(
      id: 'lifestyle_inflation_analyzer',
      name: 'Анализатор инфляции образа жизни',
      description:
          'Отслеживает рост расходов относительно роста доходов и выявляет категории с наибольшим ростом',
      type: AnalyzerType.retrospective,
      order: 4,
      tags: ['inflation', 'lifestyle', 'advanced', 'retrospective'],
      factory:
          () => LifestyleInflationAnalyzer(
            source,
            categorizer,
            PaymentExtractionService.extractPayments(source.operations) ?? [],
          ),
    );

    // Прогностические анализаторы
    _registerAnalyzer(
      id: 'predictive_analyzer',
      name: 'Предиктивный анализатор',
      description: 'Прогнозирует будущие финансовые тенденции на основе исторических данных',
      type: AnalyzerType.predictive,
      order: 6,
      tags: ['predictive', 'forecast', 'advanced', 'predictive'],
      factory: () => PredictiveAnalyzerImpl(source),
    );

    // Комбинированные анализаторы
    _registerAnalyzer(
      id: 'budget_optimization_analyzer',
      name: 'Анализатор оптимизации бюджета',
      description: 'Предлагает способы оптимизации бюджета и выявляет возможности для экономии',
      type: AnalyzerType.combined,
      order: 8,
      tags: ['optimization', 'budget', 'advanced', 'combined'],
      factory:
          () => BudgetOptimizationAnalyzer(
            source,
            categorizer,
            PaymentExtractionService.extractPayments(source.operations) ?? [],
          ),
    );

    _registerAnalyzer(
      id: 'financial_independence_analyzer',
      name: 'Анализатор финансовой независимости',
      description:
          'Рассчитывает показатели на пути к финансовой независимости и прогнозирует сроки её достижения',
      type: AnalyzerType.combined,
      order: 9,
      tags: ['independence', 'fire', 'advanced', 'combined'],
      factory: () => FinancialIndependenceAnalyzer(source),
    );
  }

  /// Регистрирует анализатор
  void _registerAnalyzer({
    required String id,
    required String name,
    required String description,
    required AnalyzerType type,
    required int order,
    required List<String> tags,
    required IFinancialAnalyzer Function() factory,
  }) {
    final descriptor = AnalyzerDescriptor(
      id: id,
      name: name,
      description: description,
      type: type,
      order: order,
      tags: tags,
    );

    _availableAnalyzers.add(descriptor);
    _analyzerFactories[id] = factory;
  }

  @override
  List<AnalyzerDescriptor> getAvailableAnalyzers() {
    // Возвращаем копию списка, отсортированную по порядку
    return List.of(_availableAnalyzers)..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  List<AnalyzerDescriptor> getAnalyzersByType(AnalyzerType type) {
    return _availableAnalyzers.where((analyzer) => analyzer.type == type).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  List<AnalyzerDescriptor> getAnalyzersByTags(List<String> tags) {
    return _availableAnalyzers
        .where((analyzer) => tags.any((tag) => analyzer.tags.contains(tag)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  List<AnalyzerDescriptor> getAnalyzersByIds(List<String> ids) {
    return _availableAnalyzers.where((analyzer) => ids.contains(analyzer.id)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  IFinancialAnalyzer createAnalyzer(String id) {
    final factory = _analyzerFactories[id];
    if (factory == null) {
      throw ArgumentError('Анализатор с идентификатором $id не найден');
    }
    return factory();
  }

  @override
  List<IFinancialAnalyzer> createAnalyzers(List<String> ids) {
    return ids.map((id) => createAnalyzer(id)).toList();
  }

  @override
  List<IFinancialAnalyzer> createAnalyzersByType(AnalyzerType type) {
    final descriptors = getAnalyzersByType(type);
    return descriptors.map((descriptor) => createAnalyzer(descriptor.id)).toList();
  }

  @override
  List<IFinancialAnalyzer> createAnalyzersByTags(List<String> tags) {
    final descriptors = getAnalyzersByTags(tags);
    return descriptors.map((descriptor) => createAnalyzer(descriptor.id)).toList();
  }

  @override
  List<IFinancialAnalyzer> createAllAnalyzers() {
    return _availableAnalyzers.map((descriptor) => createAnalyzer(descriptor.id)).toList();
  }

  @override
  void registerCustomAnalyzers(Map<String, IFinancialAnalyzer> analyzers) {
    for (final entry in analyzers.entries) {
      final id = entry.key;
      final analyzer = entry.value;

      // Создаем дескриптор на основе типа анализатора
      AnalyzerType type;
      if (analyzer is RetrospectiveAnalyzer) {
        type = AnalyzerType.retrospective;
      } else if (analyzer is PredictiveAnalyzer) {
        type = AnalyzerType.predictive;
      } else if (analyzer is CombinedAnalyzer) {
        type = AnalyzerType.combined;
      } else {
        // По умолчанию считаем анализатор ретроспективным
        type = AnalyzerType.retrospective;
      }

      // Регистрируем анализатор с базовым описанием
      _registerAnalyzer(
        id: id,
        name: 'Пользовательский анализатор',
        description: 'Пользовательский анализатор типа ${type.toString().split('.').last}',
        type: type,
        order: _availableAnalyzers.length + 1,
        tags: ['custom'],
        factory: () => analyzer,
      );
    }
  }
}
