// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expressions/expressions.dart';
import 'package:moniplan_app/features/planner/calculator/calculator_bloc/calculator_event.dart';
import 'package:moniplan_app/features/planner/calculator/calculator_bloc/calculator_state.dart';

/// Блок для управления калькулятором
class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  // Контроллер текстового поля, с которым работает калькулятор
  TextEditingController? controller;

  CalculatorBloc({this.controller}) : super(const CalculatorState()) {
    on<DigitPressed>(_onDigitPressed);
    on<BackspacePressed>(_onBackspacePressed);
    on<ClearPressed>(_onClearPressed);
    on<OperationPressed>(_onOperationPressed);
    on<EqualsPressed>(_onEqualsPressed);
    on<ToggleCalculatorMode>(_onToggleCalculatorMode);
    on<SetInitialValue>(_onSetInitialValue);
    on<UpdateFromController>(_onUpdateFromController);
    on<UpdateController>(_onUpdateController);
  }

  /// Обновляет контроллер, с которым работает блок
  void updateController(TextEditingController newController) {
    controller = newController;
    add(UpdateController(newController));
  }

  /// Обработка события обновления контроллера
  void _onUpdateController(UpdateController event, Emitter<CalculatorState> emit) {
    // Просто обновляем контроллер, состояние будет обновлено другими событиями
    controller = event.controller;
  }

  /// Обработка нажатия на цифру
  void _onDigitPressed(DigitPressed event, Emitter<CalculatorState> emit) {
    final digit = event.digit;

    if (!state.isCalculatorMode) {
      // В обычном режиме просто добавляем цифру к контроллеру
      if (controller != null) {
        final currentText = controller!.text;

        // Если текст пустой или равен "0", заменяем его на цифру
        if (currentText.isEmpty || currentText == '0') {
          controller!.text = digit;
        } else {
          // Иначе добавляем цифру в конец
          controller!.text = currentText + digit;
        }

        // Устанавливаем курсор в конец текста
        controller!.selection = TextSelection.collapsed(offset: controller!.text.length);

        // Обновляем состояние из контроллера
        add(UpdateFromController());
      }
      return;
    }

    // В режиме калькулятора
    if (controller != null) {
      if (state.hasResult) {
        // Если у нас уже есть результат, начинаем новое выражение
        controller!.text = digit;
        controller!.selection = TextSelection.collapsed(offset: 1);

        emit(
          state.copyWith(
            currentOperator: '',
            leftOperand: double.tryParse(digit) ?? 0,
            rightOperand: null,
            hasResult: false,
            result: digit,
          ),
        );
      } else if (state.currentOperator.isEmpty) {
        // Если оператор еще не выбран, добавляем цифру к левому операнду
        final currentText = controller!.text;

        // Если текст пустой или равен "0", заменяем его на цифру
        if (currentText.isEmpty || currentText == '0') {
          controller!.text = digit;
        } else {
          // Иначе добавляем цифру в конец
          controller!.text = currentText + digit;
        }

        // Устанавливаем курсор в конец текста
        controller!.selection = TextSelection.collapsed(offset: controller!.text.length);

        // Обновляем левый операнд
        final newValue = controller!.text;
        final leftOperand = double.tryParse(newValue);

        emit(state.copyWith(leftOperand: leftOperand ?? 0, result: newValue));
      } else {
        // Если оператор уже выбран, добавляем цифру к правому операнду
        final currentText = controller!.text;

        // Разбиваем текст на части по оператору
        final parts = currentText.split(' ${state.currentOperator} ');

        // Если правая часть пустая или "0", заменяем ее на цифру
        // Но сохраняем минус, если он есть
        if (parts.length == 1 || parts[1].isEmpty) {
          controller!.text = '${parts[0]} ${state.currentOperator} $digit';
        } else if (parts[1] == '0') {
          controller!.text = '${parts[0]} ${state.currentOperator} $digit';
        } else if (parts[1] == '-') {
          controller!.text = '${parts[0]} ${state.currentOperator} -$digit';
        } else {
          // Иначе добавляем цифру к правой части
          controller!.text = '${parts[0]} ${state.currentOperator} ${parts[1]}$digit';
        }

        // Устанавливаем курсор в конец текста
        controller!.selection = TextSelection.collapsed(offset: controller!.text.length);

        // Извлекаем правый операнд из выражения
        final updatedParts = controller!.text.split(' ${state.currentOperator} ');
        if (updatedParts.length > 1 && updatedParts[1].isNotEmpty) {
          final rightOperand = double.tryParse(updatedParts[1]);

          // Обновляем состояние с текущим выражением
          emit(state.copyWith(rightOperand: rightOperand, result: controller!.text));
        }
      }
    }
  }

  /// Обработка нажатия на кнопку Backspace
  void _onBackspacePressed(BackspacePressed event, Emitter<CalculatorState> emit) {
    if (controller == null) return;

    final currentText = controller!.text;
    final currentPosition = controller!.selection.baseOffset;

    // Если текст пустой или позиция курсора недействительна, ничего не делаем
    if (currentText.isEmpty || currentPosition <= 0) {
      return;
    }

    // Удаляем символ перед курсором
    final newText =
        currentText.substring(0, currentPosition - 1) + currentText.substring(currentPosition);

    controller!.text = newText;
    controller!.selection = TextSelection.collapsed(offset: currentPosition - 1);

    // Обновляем состояние из контроллера
    if (state.isCalculatorMode) {
      if (state.currentOperator.isEmpty) {
        // Если нет оператора, обновляем левый операнд
        emit(
          state.copyWith(
            leftOperand: newText.isEmpty ? 0 : (double.tryParse(newText) ?? 0),
            result: newText.isEmpty ? '0' : newText,
          ),
        );
      } else {
        // Если есть оператор, проверяем, что осталось в выражении
        final parts = newText.split(' ${state.currentOperator} ');
        if (parts.length > 1 && parts[1].isNotEmpty) {
          // Обновляем правый операнд
          final rightOperand = double.tryParse(parts[1]) ?? 0;
          emit(state.copyWith(rightOperand: rightOperand, result: newText));
        } else if (parts.length > 1 && parts[1].isEmpty) {
          // Если правый операнд пуст, удаляем оператор
          emit(state.copyWith(currentOperator: '', rightOperand: null, result: parts[0]));
        } else {
          // Если оператор удален, обновляем левый операнд
          emit(
            state.copyWith(
              leftOperand: newText.isEmpty ? 0 : (double.tryParse(newText) ?? 0),
              currentOperator: '',
              rightOperand: null,
              result: newText.isEmpty ? '0' : newText,
            ),
          );
        }
      }
    } else {
      add(UpdateFromController());
    }
  }

  /// Обработка нажатия на кнопку очистки
  void _onClearPressed(ClearPressed event, Emitter<CalculatorState> emit) {
    if (controller != null) {
      controller!.clear();
      controller!.selection = const TextSelection.collapsed(offset: 0);
    }

    emit(const CalculatorState());
  }

  /// Обработка нажатия на кнопку операции
  void _onOperationPressed(OperationPressed event, Emitter<CalculatorState> emit) {
    if (controller == null) return;

    final operation = event.operation;
    final currentText = controller!.text.trim();

    // Особая обработка для минуса в начале выражения (отрицательное число)
    if (operation == '-' && (currentText.isEmpty || currentText == '0')) {
      controller!.text = '-';
      controller!.selection = TextSelection.collapsed(offset: 1);

      emit(state.copyWith(result: '-'));
      return;
    }

    // Особая обработка для минуса после оператора (отрицательное число)
    if (operation == '-' && state.currentOperator.isNotEmpty) {
      final parts = currentText.split(' ${state.currentOperator} ');
      if (parts.length > 1 && parts[1].isEmpty) {
        controller!.text = '${parts[0]} ${state.currentOperator} -';
        controller!.selection = TextSelection.collapsed(offset: controller!.text.length);

        emit(state.copyWith(result: controller!.text));
        return;
      }
    }

    // Проверяем, что текущее значение является числом
    final currentValue = double.tryParse(currentText);
    if (currentValue == null && !currentText.contains(' ') && currentText != '-') {
      // Если текущее значение не является числом и не содержит оператора, ничего не делаем
      return;
    }

    if (!state.isCalculatorMode) {
      // Переключаемся в режим калькулятора
      emit(
        state.copyWith(
          isCalculatorMode: true,
          leftOperand: double.tryParse(currentText) ?? 0,
          result: currentText,
        ),
      );
    }

    // Если у нас уже есть результат, используем его как левый операнд для нового выражения
    if (state.hasResult) {
      controller!.text = '${state.result} $operation ';
      controller!.selection = TextSelection.collapsed(offset: controller!.text.length);

      emit(
        state.copyWith(
          currentOperator: operation,
          leftOperand: double.tryParse(state.result) ?? 0,
          rightOperand: null,
          hasResult: false,
          result: controller!.text,
        ),
      );
      return;
    }

    // Проверяем, содержит ли текст уже операцию
    final containsPlus = currentText.contains(' + ');
    final containsMinus = currentText.contains(' - ');
    final containsMultiply = currentText.contains(' × ');
    final containsDivide = currentText.contains(' ÷ ');

    if (containsPlus || containsMinus || containsMultiply || containsDivide) {
      // Проверяем, есть ли правый операнд
      final parts = currentText.split(' ${state.currentOperator} ');
      if (parts.length > 1 && parts[1].trim().isEmpty) {
        // Если правый операнд пуст, просто заменяем оператор
        controller!.text = '${parts[0]} $operation ';
        controller!.selection = TextSelection.collapsed(offset: controller!.text.length);

        // Обновляем состояние
        emit(state.copyWith(currentOperator: operation, result: controller!.text));
        return;
      }

      // Если выражение уже содержит оператор и правый операнд, вычисляем результат
      final result = state.calculateResult(currentText, isEquals: true);
      emit(result);

      // Добавляем оператор к результату
      controller!.text = '${result.result} $operation ';
      controller!.selection = TextSelection.collapsed(offset: controller!.text.length);

      // Обновляем состояние
      emit(
        state.copyWith(
          currentOperator: operation,
          leftOperand: double.tryParse(result.result) ?? 0,
          rightOperand: null,
          hasResult: false,
          result: controller!.text,
        ),
      );
    } else {
      // Если выражение не содержит оператора, добавляем его
      controller!.text = '$currentText $operation ';
      controller!.selection = TextSelection.collapsed(offset: controller!.text.length);

      // Обновляем состояние
      emit(
        state.copyWith(
          currentOperator: operation,
          leftOperand: double.tryParse(currentText) ?? 0,
          rightOperand: null,
          hasResult: false,
          result: controller!.text,
        ),
      );
    }
  }

  /// Обработка нажатия на кнопку "="
  void _onEqualsPressed(EqualsPressed event, Emitter<CalculatorState> emit) {
    if (controller == null) return;

    final currentText = controller!.text;

    // Проверяем, содержит ли текст операцию
    final containsOperator =
        currentText.contains(' + ') ||
        currentText.contains(' - ') ||
        currentText.contains(' × ') ||
        currentText.contains(' ÷ ');

    if (!containsOperator) {
      // Если нет операции, просто возвращаем текущее значение
      return;
    }

    // Вычисляем результат
    final result = state.calculateResult(currentText, isEquals: true);

    // Обновляем текст контроллера
    controller!.text = result.result;
    controller!.selection = TextSelection.collapsed(offset: result.result.length);

    // Обновляем состояние
    emit(result);
  }

  /// Обработка переключения режима калькулятора
  void _onToggleCalculatorMode(ToggleCalculatorMode event, Emitter<CalculatorState> emit) {
    emit(state.copyWith(isCalculatorMode: event.isCalculatorMode));

    if (event.isCalculatorMode && controller != null) {
      // При переключении в режим калькулятора, обновляем левый операнд
      final currentText = controller!.text;
      final currentValue = double.tryParse(currentText) ?? 0;
      emit(state.copyWith(leftOperand: currentValue, result: currentText));
    }
  }

  /// Обработка установки начального значения
  void _onSetInitialValue(SetInitialValue event, Emitter<CalculatorState> emit) {
    if (controller != null) {
      controller!.text = event.value;
      controller!.selection = TextSelection.collapsed(offset: event.value.length);
    }

    final value = double.tryParse(event.value) ?? 0;
    emit(
      state.copyWith(
        result: event.value,
        leftOperand: value,
        currentOperator: '',
        rightOperand: null,
        hasResult: false,
      ),
    );
  }

  /// Обработка обновления состояния из контроллера
  void _onUpdateFromController(UpdateFromController event, Emitter<CalculatorState> emit) {
    if (controller == null) return;

    final text = controller!.text;
    final value = double.tryParse(text) ?? 0;

    emit(state.copyWith(result: text.isEmpty ? '0' : text, leftOperand: value));
  }
}
