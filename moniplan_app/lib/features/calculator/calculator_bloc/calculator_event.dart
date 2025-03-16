// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:equatable/equatable.dart';

/// События для блока калькулятора
abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object?> get props => [];
}

/// Добавление цифры
class DigitPressed extends CalculatorEvent {
  final String digit;

  const DigitPressed(this.digit);

  @override
  List<Object?> get props => [digit];
}

/// Удаление последнего символа
class BackspacePressed extends CalculatorEvent {}

/// Очистка всего ввода
class ClearPressed extends CalculatorEvent {}

/// Применение арифметической операции
class OperationPressed extends CalculatorEvent {
  /// Символ операции ('+', '-', '×', '÷')
  final String operation;

  const OperationPressed(this.operation);

  @override
  List<Object?> get props => [operation];
}

/// Вычисление результата
class EqualsPressed extends CalculatorEvent {}

/// Установка начального значения
class SetInitialValue extends CalculatorEvent {
  final String value;

  const SetInitialValue(this.value);

  @override
  List<Object?> get props => [value];
}

/// Сброс значения
class ResetPressed extends CalculatorEvent {}
