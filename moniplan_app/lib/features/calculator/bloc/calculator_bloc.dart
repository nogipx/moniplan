// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:rpc_dart/logger.dart';

import '_index.dart';

/// Блок для управления калькулятором
class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final _log = RpcLogger('CalculatorBloc');

  CalculatorBloc() : super(const CalculatorState()) {
    on<CalculatorEvent>(
      (event, emit) => switch (event) {
        DigitPressed() => _onDigitPressed(event, emit),
        BackspacePressed() => _onBackspacePressed(event, emit),
        ClearPressed() => _onClearPressed(event, emit),
        OperationPressed() => _onOperationPressed(event, emit),
        EqualsPressed() => _onEqualsPressed(event, emit),
        SetInitialValue() => _onSetInitialValue(event, emit),
        ResetPressed() => _onResetPressed(event, emit),
        _ => null,
      },
      transformer: sequential(),
    );
  }

  /// Обработка нажатия на цифру
  void _onDigitPressed(DigitPressed event, Emitter<CalculatorState> emit) {
    final digit = event.digit;

    // Если у нас уже есть результат, начинаем новое выражение
    if (state.hasResult) {
      final newState = state.copyWith(
        result: digit,
        leftOperand: double.tryParse(digit) ?? 0,
        currentOperator: CalculatorOperator.none,
        rightOperand: null,
        hasResult: false,
      );
      emit(newState);
      return;
    }

    // Если оператор еще не выбран, добавляем цифру к левому операнду
    if (state.currentOperator == CalculatorOperator.none) {
      String newResult;

      // Если текущий результат "0", заменяем его на цифру
      if (state.result == '0') {
        newResult = digit;
      } else {
        // Иначе добавляем цифру в конец
        newResult = state.result + digit;
      }

      final newState = state.copyWith(
        result: newResult,
        leftOperand: double.tryParse(newResult) ?? 0,
      );
      emit(newState);
    } else {
      // Если оператор уже выбран, добавляем цифру к правому операнду
      String leftPart = state.result;
      String rightPart = '';

      // Разбиваем текст на части по оператору
      if (state.result.contains(' ${state.currentOperator.symbol} ')) {
        final parts = state.result.split(' ${state.currentOperator.symbol} ');
        leftPart = parts[0];
        if (parts.length > 1) {
          rightPart = parts[1];
        }
      }

      // Обновляем правую часть
      String newRightPart;
      if (rightPart.isEmpty || rightPart == '0') {
        newRightPart = digit;
      } else {
        newRightPart = rightPart + digit;
      }

      // Формируем новый результат
      final newResult = '$leftPart ${state.currentOperator.symbol} $newRightPart';

      final newState = state.copyWith(
        result: newResult,
        rightOperand: double.tryParse(newRightPart) ?? 0,
      );
      emit(newState);
    }
  }

  /// Обработка нажатия на кнопку Backspace
  void _onBackspacePressed(BackspacePressed event, Emitter<CalculatorState> emit) {
    // Если результат уже вычислен, ничего не делаем
    if (state.hasResult) {
      return;
    }

    // Если результат пустой или "0", ничего не делаем
    if (state.result.isEmpty || state.result == '0') {
      return;
    }

    // Если оператор не выбран, удаляем последний символ из левого операнда
    if (state.currentOperator == CalculatorOperator.none) {
      String newResult = state.result.substring(0, state.result.length - 1);
      if (newResult.isEmpty) {
        newResult = '0';
      }

      final newState = state.copyWith(
        result: newResult,
        leftOperand: newResult == '0' ? 0 : (double.tryParse(newResult) ?? 0),
      );
      emit(newState);
    } else {
      // Если оператор выбран, проверяем, что удаляем
      final parts = state.result.split(' ${state.currentOperator.symbol} ');
      final leftPart = parts[0];
      String rightPart = '';
      if (parts.length > 1) {
        rightPart = parts[1];
      }

      // Если правая часть не пуста, удаляем из нее
      if (rightPart.isNotEmpty) {
        final newRightPart = rightPart.substring(0, rightPart.length - 1);
        final newResult =
            newRightPart.isEmpty
                ? '$leftPart ${state.currentOperator.symbol} '
                : '$leftPart ${state.currentOperator.symbol} $newRightPart';

        final newState = state.copyWith(
          result: newResult,
          rightOperand: newRightPart.isEmpty ? null : (double.tryParse(newRightPart) ?? 0),
        );
        emit(newState);
      } else {
        // Если правая часть пуста, удаляем оператор
        final newState = state.copyWith(
          result: leftPart,
          currentOperator: CalculatorOperator.none,
          rightOperand: null,
        );
        emit(newState);
      }
    }
  }

  /// Обработка нажатия на кнопку очистки
  void _onClearPressed(ClearPressed event, Emitter<CalculatorState> emit) {
    final newState = const CalculatorState();
    emit(newState);
  }

  /// Обработка нажатия на кнопку операции
  void _onOperationPressed(OperationPressed event, Emitter<CalculatorState> emit) {
    final operation = CalculatorOperator.fromSymbol(event.operation);

    // Если результат пустой, ничего не делаем
    if (state.result.isEmpty) {
      return;
    }

    // Если у нас уже есть результат, используем его как левый операнд
    if (state.hasResult) {
      final newResult = '${state.result} ${operation.symbol} ';
      final newState = state.copyWith(
        result: newResult,
        currentOperator: operation,
        rightOperand: null,
        hasResult: false,
      );
      emit(newState);
      return;
    }

    // Если оператор не выбран, добавляем его
    if (state.currentOperator == CalculatorOperator.none) {
      final newResult = '${state.result} ${operation.symbol} ';
      final newState = state.copyWith(result: newResult, currentOperator: operation);
      emit(newState);
      return;
    }

    // Если оператор уже выбран, проверяем, есть ли правый операнд
    final parts = state.result.split(' ${state.currentOperator.symbol} ');
    final leftPart = parts[0];
    String rightPart = '';
    if (parts.length > 1) {
      rightPart = parts[1];
    }

    // Если правый операнд пуст и нажат тот же оператор, убираем оператор
    if (rightPart.isEmpty && operation == state.currentOperator) {
      final newState = state.copyWith(
        result: leftPart,
        currentOperator: CalculatorOperator.none,
        rightOperand: null,
      );
      emit(newState);
      return;
    }

    // Если правый операнд пуст, просто заменяем оператор
    if (rightPart.isEmpty) {
      final newResult = '$leftPart ${operation.symbol} ';
      final newState = state.copyWith(result: newResult, currentOperator: operation);
      emit(newState);
      return;
    }

    // Если правый операнд не пуст, вычисляем результат и добавляем новый оператор
    try {
      // Вычисляем результат
      double result = _calculateResult(
        state.leftOperand,
        state.rightOperand ?? 0,
        state.currentOperator,
      );

      // Форматируем результат
      final formattedResult =
          result == result.toInt() ? result.toInt().toString() : result.toString();

      // Формируем новый результат с оператором
      final newResult = '$formattedResult ${operation.symbol} ';

      final newState = state.copyWith(
        result: newResult,
        leftOperand: result,
        rightOperand: null,
        currentOperator: operation,
        hasResult: false,
      );
      emit(newState);
    } catch (e) {
      _log.error('Ошибка при вычислении: $e');
      // В случае ошибки просто заменяем оператор
      final newResult = '$leftPart ${operation.symbol} ';
      final newState = state.copyWith(
        result: newResult,
        currentOperator: operation,
        rightOperand: null,
      );
      emit(newState);
    }
  }

  /// Обработка нажатия на кнопку "="
  void _onEqualsPressed(EqualsPressed event, Emitter<CalculatorState> emit) {
    // Если результат пустой или уже вычислен, ничего не делаем
    if (state.result.isEmpty || state.hasResult) {
      return;
    }

    // Если оператор не выбран, ничего не делаем
    if (state.currentOperator == CalculatorOperator.none) {
      return;
    }

    // Проверяем, есть ли правый операнд
    final parts = state.result.split(' ${state.currentOperator.symbol} ');
    final leftPart = parts[0];
    String rightPart = '';
    if (parts.length > 1) {
      rightPart = parts[1];
    }

    // Если правый операнд пуст или не является числом, ничего не делаем
    if (rightPart.isEmpty || double.tryParse(rightPart) == null) {
      return;
    }

    // Вычисляем результат
    try {
      // Вычисляем результат
      double result = _calculateResult(
        state.leftOperand,
        state.rightOperand ?? 0,
        state.currentOperator,
      );

      // Форматируем результат
      final formattedResult =
          result == result.toInt() ? result.toInt().toString() : result.toString();

      final newState = state.copyWith(
        result: formattedResult,
        leftOperand: result,
        rightOperand: null,
        currentOperator: CalculatorOperator.none,
        hasResult: true,
      );
      emit(newState);
    } catch (e) {
      _log.error('Ошибка при вычислении: $e');
      // В случае ошибки просто возвращаем левую часть
      final newState = state.copyWith(
        result: leftPart,
        currentOperator: CalculatorOperator.none,
        rightOperand: null,
      );
      emit(newState);
    }
  }

  /// Вычисляет результат арифметической операции
  double _calculateResult(double left, double right, CalculatorOperator operator) {
    switch (operator) {
      case CalculatorOperator.add:
        return left + right;
      case CalculatorOperator.subtract:
        return left - right;
      case CalculatorOperator.multiply:
        return left * right;
      case CalculatorOperator.divide:
        if (right != 0) {
          return left / right;
        } else {
          return left; // Защита от деления на ноль
        }
      default:
        return left;
    }
  }

  /// Обработка установки начального значения
  void _onSetInitialValue(SetInitialValue event, Emitter<CalculatorState> emit) {
    final value = double.tryParse(event.value) ?? 0;

    // Проверяем, является ли число целым
    final isInteger = value == value.toInt();
    final leftOperand = isInteger ? value.toInt().toDouble() : value;

    // Форматируем результат для отображения
    final formattedResult = CalculatorState.formatNumber(value);

    final newState = CalculatorState(
      result: formattedResult,
      leftOperand: leftOperand,
      currentOperator: CalculatorOperator.none,
      rightOperand: null,
      hasResult: false,
      initialValue: event.value,
    );
    emit(newState);
  }

  /// Обработка сброса значения
  void _onResetPressed(ResetPressed event, Emitter<CalculatorState> emit) {
    final newState = CalculatorState(initialValue: state.initialValue, result: state.initialValue);
    emit(newState);
  }
}
