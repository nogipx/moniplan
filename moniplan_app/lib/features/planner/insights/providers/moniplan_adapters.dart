// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// Адаптер для преобразования платежа Moniplan в абстрактные финансовые данные
class MoniplanPaymentFinancialData implements IFinancialData {
  final Payment _payment;

  /// Конструктор
  MoniplanPaymentFinancialData(this._payment);

  @override
  String get id => _payment.paymentId;

  @override
  DateTime get date => _payment.date;

  @override
  num get amount => _payment.details.normalizedMoney;

  @override
  String get category => _payment.details.name;

  @override
  FinancialOperationType get type {
    switch (_payment.type) {
      case PaymentType.income:
        return FinancialOperationType.income;
      case PaymentType.expense:
        return FinancialOperationType.expense;
      default:
        return FinancialOperationType.other;
    }
  }

  @override
  FinancialOperationStatus get status {
    if (_payment.isDone) {
      return FinancialOperationStatus.completed;
    } else if (_payment.isEnabled) {
      return FinancialOperationStatus.planned;
    } else {
      return FinancialOperationStatus.cancelled;
    }
  }

  @override
  Map<String, dynamic>? get additionalData => {
    'isEnabled': _payment.isEnabled,
    'isDone': _payment.isDone,
    'originalPayment': _payment,
  };

  /// Преобразует список платежей Moniplan в список абстрактных финансовых данных
  static List<IFinancialData> fromPaymentList(List<Payment> payments) {
    return payments.map((payment) => MoniplanPaymentFinancialData(payment)).toList();
  }

  /// Получает оригинальный платеж Moniplan
  Payment get originalPayment => _payment;
}

/// Адаптер для преобразования планера Moniplan в абстрактный финансовый период
class MoniplanPlannerFinancialSource implements IFinancialSource {
  final Planner _planner;
  final List<IFinancialData> _operations;

  /// Конструктор
  MoniplanPlannerFinancialSource(this._planner)
    : _operations = MoniplanPaymentFinancialData.fromPaymentList(_planner.payments);

  @override
  String get id => _planner.id;

  @override
  String get name => _planner.name;

  @override
  DateTime get startDate => _planner.dateStart;

  @override
  DateTime? get endDate => _planner.dateEnd;

  @override
  List<IFinancialData> get operations => _operations;

  @override
  num get initialBudget => _planner.initialBudget;

  @override
  Map<String, dynamic>? get additionalData => {
    'isGenerationAllowed': _planner.isGenerationAllowed,
    'actualInfo': _planner.actualInfo,
    'originalPlanner': _planner,
  };

  /// Получает оригинальный планер Moniplan
  Planner get originalPlanner => _planner;

  /// Получает список завершенных операций
  List<IFinancialData> get completedOperations =>
      operations.where((op) => op.status == FinancialOperationStatus.completed).toList();

  /// Получает список запланированных операций
  List<IFinancialData> get plannedOperations =>
      operations.where((op) => op.status == FinancialOperationStatus.planned).toList();

  /// Получает список расходов
  List<IFinancialData> get expenses =>
      operations.where((op) => op.type == FinancialOperationType.expense).toList();

  /// Получает список доходов
  List<IFinancialData> get incomes =>
      operations.where((op) => op.type == FinancialOperationType.income).toList();
}
