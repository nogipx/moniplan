// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import '../_index.dart';

/// Результат анализа данных
class AnalysisResult {
  /// Список инсайтов
  final List<Insight> insights;

  /// Дополнительные данные, полученные в результате анализа
  final Map<String, dynamic> analysisData;

  /// Конструктор
  AnalysisResult({required this.insights, required this.analysisData});

  /// Конструктор
  AnalysisResult.empty() : insights = [], analysisData = {};
}

/// Базовый интерфейс для всех анализаторов финансовых данных
abstract interface class IFinancialAnalyzer {
  /// Текущий источник данных
  abstract final IFinancialSource source;

  /// Возвращает все доступные операции для анализа
  List<IFinancialData> get availableOperations;

  /// Выполняет анализ и возвращает список инсайтов
  ///
  /// [analysisData] - дополнительные данные для анализа (опционально)
  AnalysisResult analyze({Map<String, dynamic>? analysisData});
}

/// Базовый класс для ретроспективных анализаторов
abstract base class IBaseFinancialAnalyzer implements IFinancialAnalyzer {
  final IFinancialSource? _source;

  IBaseFinancialAnalyzer(this._source);

  @override
  IFinancialSource get source => _source!;

  @override
  List<IFinancialData> get availableOperations;

  @override
  AnalysisResult analyze({Map<String, dynamic>? analysisData}) => throw UnimplementedError();

  /// Возвращает операции, отфильтрованные по временному признаку
  ///
  /// [timeframe] - временной признак для фильтрации
  ///
  /// Для retrospective возвращает только завершенные операции
  /// Для predictive возвращает только запланированные операции
  /// Для combined возвращает все операции
  List<IFinancialData> _getFilteredOperations(InsightTimeframe timeframe) {
    switch (timeframe) {
      case InsightTimeframe.retrospective:
        return source.operations
            .where((op) => op.status == FinancialOperationStatus.completed)
            .toList();
      case InsightTimeframe.predictive:
        return source.operations
            .where((op) => op.status == FinancialOperationStatus.planned)
            .toList();
      case InsightTimeframe.combined:
        return source.operations;
    }
  }
}

/// Интерфейс для анализаторов ретроспективных данных
abstract base class RetrospectiveAnalyzer extends IBaseFinancialAnalyzer {
  RetrospectiveAnalyzer(super.source);
  @override
  List<IFinancialData> get availableOperations =>
      _getFilteredOperations(InsightTimeframe.retrospective);
}

/// Интерфейс для анализаторов прогностических данных
abstract base class PredictiveAnalyzer extends IBaseFinancialAnalyzer {
  PredictiveAnalyzer(super.source);
  @override
  List<IFinancialData> get availableOperations =>
      _getFilteredOperations(InsightTimeframe.predictive);
}

/// Интерфейс для анализаторов комбинированных данных
abstract base class CombinedAnalyzer extends IBaseFinancialAnalyzer {
  CombinedAnalyzer(super.source);
  @override
  List<IFinancialData> get availableOperations => _getFilteredOperations(InsightTimeframe.combined);
}
