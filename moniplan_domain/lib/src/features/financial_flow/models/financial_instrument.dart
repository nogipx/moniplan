// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

part 'financial_instrument.freezed.dart';
part 'financial_instrument.g.dart';

/// Тип финансового инструмента
enum FinancialInstrumentType {
  /// Обычный доход (зарплата, подработка)
  regularIncome(1, 'Регулярный доход'),
  
  /// Обычный расход (продукты, транспорт)
  regularExpense(2, 'Регулярный расход'),
  
  /// Кредитный платеж
  creditPayment(3, 'Кредитный платеж'),
  
  /// Займ (выдача денег)
  loanPayment(4, 'Займ'),
  
  /// Инвестиции
  investment(5, 'Инвестиции'),
  
  /// Разовый доход
  oneTimeIncome(6, 'Разовый доход'),
  
  /// Разовый расход
  oneTimeExpense(7, 'Разовый расход');

  const FinancialInstrumentType(this.id, this.displayName);
  
  final int id;
  final String displayName;
  
  bool get isIncome => this == regularIncome || this == oneTimeIncome;
  bool get isExpense => this == regularExpense || this == oneTimeExpense || this == creditPayment;
  bool get isCredit => this == creditPayment;
  bool get isRegular => this == regularIncome || this == regularExpense || this == creditPayment;
}

/// Базовая модель финансового инструмента
@freezed
class FinancialInstrument with _$FinancialInstrument {
  const FinancialInstrument._();

  @CurrencyConverter()
  @JsonSerializable()
  const factory FinancialInstrument({
    /// Уникальный идентификатор
    required String id,
    
    /// Название инструмента
    required String name,
    
    /// Описание
    @Default('') String description,
    
    /// Тип инструмента
    required FinancialInstrumentType type,
    
    /// Валюта
    required CurrencyData currency,
    
    /// Основная сумма
    @Default(0) num amount,
    
    /// Теги для категоризации
    @Default({}) Set<String> tags,
    
    /// Активен ли инструмент
    @Default(true) bool isActive,
    
    /// Данные для кредитов (если применимо)
    CreditData? creditData,
    
    /// Периодичность для регулярных платежей
    @Default(DateTimeRepeat.noRepeat) @DateTimeRepeatConverter() DateTimeRepeat repeat,
    
    /// Дата начала действия
    DateTime? startDate,
    
    /// Дата окончания действия
    DateTime? endDate,
    
    /// Дополнительные метаданные
    @Default({}) Map<String, dynamic> metadata,
  }) = _FinancialInstrument;

  factory FinancialInstrument.fromJson(Map<String, dynamic> json) => 
      _$FinancialInstrumentFromJson(json);

  /// Возвращает нормализованную сумму с учетом типа
  num get normalizedAmount {
    if (type.isIncome) return amount.abs();
    if (type.isExpense) return -amount.abs();
    return amount;
  }
  
  /// Возвращает месячную сумму для кредита
  num get monthlyAmount {
    if (type.isCredit && creditData != null) {
      return -creditData!.monthlyPayment.abs();
    }
    return normalizedAmount;
  }
  
  /// Проверяет, действует ли инструмент в указанную дату
  bool isActiveAtDate(DateTime date) {
    if (!isActive) return false;
    
    if (startDate != null && date.isBefore(startDate!)) return false;
    if (endDate != null && date.isAfter(endDate!)) return false;
    
    return true;
  }
}

/// Данные для кредитных инструментов
@freezed
class CreditData with _$CreditData {
  const CreditData._();

  @CurrencyConverter()
  @JsonSerializable()
  const factory CreditData({
    /// Общая сумма кредита
    @Default(0) num totalAmount,
    
    /// Ежемесячный платеж
    @Default(0) num monthlyPayment,
    
    /// Процентная ставка (годовая)
    @Default(0.0) double interestRate,
    
    /// Срок кредита в месяцах
    @Default(0) int termMonths,
    
    /// Остаток задолженности
    @Default(0) num remainingAmount,
    
    /// Дата выдачи кредита
    DateTime? issueDate,
    
    /// Дата последнего платежа
    DateTime? lastPaymentDate,
    
    /// Тип кредита (аннуитетный, дифференцированный)
    @Default(CreditType.annuity) CreditType creditType,
  }) = _CreditData;

  factory CreditData.fromJson(Map<String, dynamic> json) => 
      _$CreditDataFromJson(json);
      
  /// Вычисляет остаток на указанную дату
  num calculateRemainingAmount(DateTime date) {
    if (issueDate == null) return remainingAmount;
    
    final monthsPassed = date.difference(issueDate!).inDays ~/ 30;
    if (monthsPassed <= 0) return totalAmount;
    
    // Упрощенный расчет для аннуитетного кредита
    if (creditType == CreditType.annuity) {
      final monthlyRate = interestRate / 12 / 100;
      if (monthlyRate == 0) {
        return totalAmount - (monthlyPayment * monthsPassed);
      }
      
      final remaining = totalAmount * 
          (pow(1 + monthlyRate, termMonths) - pow(1 + monthlyRate, monthsPassed)) /
          (pow(1 + monthlyRate, termMonths) - 1);
      
      return remaining > 0 ? remaining : 0;
    }
    
    return remainingAmount;
  }
}

/// Тип кредита
enum CreditType {
  /// Аннуитетный (равные платежи)
  annuity('annuity', 'Аннуитетный'),
  
  /// Дифференцированный (убывающие платежи)
  differentiated('differentiated', 'Дифференцированный');

  const CreditType(this.value, this.displayName);
  
  final String value;
  final String displayName;
}
