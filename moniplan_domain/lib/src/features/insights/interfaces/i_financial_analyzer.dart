// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/src/features/payment/models/payment/payment.dart';
import 'package:uuid/uuid.dart';
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

  /// Создает инсайт с добавлением информации об анализаторе
  ///
  /// [title] - заголовок инсайта
  /// [description] - описание инсайта
  /// [type] - тип инсайта
  /// [importance] - важность инсайта
  /// [timeframe] - временной признак инсайта
  /// [relatedPayments] - связанные платежи
  /// [additionalData] - дополнительные данные
  Insight createInsight({
    required String title,
    required String description,
    required InsightType type,
    required InsightImportance importance,
    InsightTimeframe timeframe = InsightTimeframe.combined,
    List<Payment>? relatedPayments,
    Map<String, dynamic>? additionalData,
  });
}

/// Базовый класс для ретроспективных анализаторов
abstract base class IBaseFinancialAnalyzer implements IFinancialAnalyzer {
  static final _uuid = Uuid();
  final IFinancialSource? _source;

  IBaseFinancialAnalyzer(this._source);

  @override
  IFinancialSource get source => _source!;

  @override
  List<IFinancialData> get availableOperations;

  @override
  AnalysisResult analyze({Map<String, dynamic>? analysisData}) => throw UnimplementedError();

  @override
  Insight createInsight({
    required String title,
    required String description,
    required InsightType type,
    required InsightImportance importance,
    InsightTimeframe timeframe = InsightTimeframe.combined,
    List<Payment>? relatedPayments,
    Map<String, dynamic>? additionalData,
  }) {
    final id = _uuid.v4();
    // Создаем копию дополнительных данных, чтобы не изменять оригинал
    final Map<String, dynamic> data =
        additionalData != null ? Map<String, dynamic>.from(additionalData) : {};

    // Добавляем информацию об анализаторе
    data['analyzerType'] = runtimeType.toString();

    return Insight(
      id: id,
      title: title,
      description: description,
      type: type,
      importance: importance,
      timeframe: timeframe,
      relatedPayments: relatedPayments,
      additionalData: data,
    );
  }

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
