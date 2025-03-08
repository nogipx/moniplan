// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import '../interfaces/i_financial_data.dart';

/// Интерфейс для сервиса предсказания категорий
abstract class ICategoryPredictor {
  /// Возвращает true, если сервис инициализирован
  bool get isInitialized;

  /// Инициализирует сервис
  Future<void> initialize();

  /// Предсказывает категорию для финансовой операции
  Future<String> predictCategory(IFinancialData operation);

  /// Предсказывает категории для списка финансовых операций
  Future<List<IFinancialData>> predictCategories(List<IFinancialData> operations);
}
