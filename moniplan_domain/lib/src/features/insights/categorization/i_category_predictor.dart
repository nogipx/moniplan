// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// Интерфейс для сервиса предсказания категорий
abstract class ICategoryPredictor {
  /// Возвращает true, если сервис инициализирован
  bool get isInitialized;

  /// Инициализирует сервис
  Future<void> initialize();

  /// Предсказывает категорию для финансовой операции
  Future<List<CategoryPrediction>> predictCategory(Payment operation);
}

/// Модель категоризации платежа
class CategoryPrediction {
  final String category;
  final double probability;

  CategoryPrediction({required this.category, required this.probability});

  @override
  String toString() => '$category (${(probability * 100).toStringAsFixed(1)}%)';
}
