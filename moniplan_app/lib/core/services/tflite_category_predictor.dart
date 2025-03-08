// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_app/core/services/payment_categorizer_service.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

/// Реализация ICategoryPredictor на основе TensorFlow Lite модели
class TFLiteCategoryPredictor implements ICategoryPredictor {
  /// Сервис категоризации платежей
  final PaymentCategorizerService _service;

  /// Конструктор
  TFLiteCategoryPredictor(this._service);

  @override
  bool get isInitialized => _service.isInitialized;

  @override
  Future<void> initialize() async {
    if (!_service.isInitialized) {
      await _service.initialize();
    }
  }

  @override
  Future<String> predictCategory(IFinancialData operation) async {
    if (!isInitialized) {
      await initialize();
    }

    // Получаем описание операции
    final description = _getOperationDescription(operation);

    // Определяем, является ли операция доходом
    final isIncome = operation.type == FinancialOperationType.income;

    // Получаем предсказания категорий
    final predictions = await _service.predictCategory(description, isIncome);

    // Если есть предсказания, возвращаем категорию с наибольшей вероятностью
    if (predictions.isNotEmpty) {
      return predictions.first.category;
    }

    // Если предсказаний нет, возвращаем категорию по умолчанию
    return isIncome ? 'Доход' : 'Прочие расходы';
  }

  @override
  Future<List<IFinancialData>> predictCategories(List<IFinancialData> operations) async {
    if (!isInitialized) {
      await initialize();
    }

    final categorizedOperations = <IFinancialData>[];

    for (final operation in operations) {
      // Если у операции уже есть категория, оставляем её
      if (operation.category.isNotEmpty) {
        categorizedOperations.add(operation);
        continue;
      }

      // Предсказываем категорию
      final category = await predictCategory(operation);

      // Создаем новый объект с категорией
      final categorizedOperation = _CategorizedFinancialData(
        originalData: operation,
        category: category,
      );

      categorizedOperations.add(categorizedOperation);
    }

    return categorizedOperations;
  }

  /// Получает описание операции
  String _getOperationDescription(IFinancialData operation) {
    // Пытаемся получить описание из дополнительных данных
    final additionalData = operation.additionalData;
    if (additionalData != null) {
      // Проверяем, есть ли оригинальный платеж
      final originalPayment = additionalData['originalPayment'];
      if (originalPayment is Payment) {
        return originalPayment.details.name;
      }

      // Проверяем, есть ли описание
      final description = additionalData['description'];
      if (description is String && description.isNotEmpty) {
        return description;
      }
    }

    // Если не удалось получить описание, используем категорию
    return operation.category.isNotEmpty ? operation.category : 'Операция';
  }
}

/// Вспомогательный класс для хранения категоризированных финансовых данных
class _CategorizedFinancialData implements IFinancialData {
  final IFinancialData _originalData;
  final String _category;

  _CategorizedFinancialData({required IFinancialData originalData, required String category})
    : _originalData = originalData,
      _category = category;

  @override
  String get id => _originalData.id;

  @override
  DateTime get date => _originalData.date;

  @override
  num get amount => _originalData.amount;

  @override
  String get category => _category;

  @override
  FinancialOperationType get type => _originalData.type;

  @override
  FinancialOperationStatus get status => _originalData.status;

  @override
  Map<String, dynamic>? get additionalData => {
    ..._originalData.additionalData ?? {},
    'originalCategory': _originalData.category,
  };
}
