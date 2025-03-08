// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/// Базовый интерфейс для финансовых данных
abstract interface class IFinancialData {
  /// Уникальный идентификатор данных
  String get id;

  /// Дата операции
  DateTime get date;

  /// Сумма операции (положительная для доходов, отрицательная для расходов)
  num get amount;

  /// Название или категория операции
  String get category;

  /// Тип операции (доход/расход)
  FinancialOperationType get type;

  /// Статус операции (завершена/запланирована)
  FinancialOperationStatus get status;

  /// Дополнительные данные
  Map<String, dynamic>? get additionalData;
}

/// Тип финансовой операции
enum FinancialOperationType {
  /// Доход
  income,

  /// Расход
  expense,

  /// Перевод между счетами
  transfer,

  /// Другое
  other,
}

/// Статус финансовой операции
enum FinancialOperationStatus {
  /// Завершена
  completed,

  /// Запланирована
  planned,

  /// Отменена
  cancelled,

  /// В обработке
  processing,
}

/// Интерфейс для финансового периода
abstract interface class IFinancialSource {
  /// Уникальный идентификатор периода
  String get id;

  /// Название периода
  String get name;

  /// Дата начала периода
  DateTime get startDate;

  /// Дата окончания периода (может быть null для открытых периодов)
  DateTime? get endDate;

  /// Список финансовых операций в периоде
  List<IFinancialData> get operations;

  /// Начальный бюджет периода
  num get initialBudget;

  /// Дополнительные данные
  Map<String, dynamic>? get additionalData;
}
