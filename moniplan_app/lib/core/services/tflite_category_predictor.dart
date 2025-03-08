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
  Future<List<CategoryPrediction>> predictCategory(Payment operation) async {
    if (!isInitialized) {
      await initialize();
    }

    // Получаем описание операции
    final description = operation.details.name;

    // Определяем, является ли операция доходом
    final isIncome = operation.type == PaymentType.income;

    // Получаем предсказания категорий
    final predictions = await _service.predict(description, isIncome);

    // Если есть предсказания, возвращаем категорию с наибольшей вероятностью
    return predictions;
  }
}
