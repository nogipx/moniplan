import 'package:equatable/equatable.dart';
import 'package:expressions/expressions.dart';

import '../models/calculator_operator.dart';

/// Состояние калькулятора
class CalculatorState extends Equatable {
  /// Начальное значение
  final String initialValue;

  /// Текущий результат вычисления
  final String result;

  /// Левый операнд
  final double leftOperand;

  /// Правый операнд
  final double? rightOperand;

  /// Текущий оператор
  final CalculatorOperator currentOperator;

  /// Флаг, указывающий, что результат вычислен
  final bool hasResult;

  /// Режим калькулятора активен
  final bool isCalculatorMode;

  const CalculatorState({
    this.initialValue = '',
    this.result = '0',
    this.leftOperand = 0,
    this.rightOperand,
    this.currentOperator = CalculatorOperator.none,
    this.hasResult = false,
    this.isCalculatorMode = false,
  });

  /// Создает копию состояния с новыми значениями
  CalculatorState copyWith({
    String? result,
    double? leftOperand,
    double? rightOperand,
    CalculatorOperator? currentOperator,
    bool? hasResult,
    bool? isCalculatorMode,
  }) {
    return CalculatorState(
      result: result ?? this.result,
      leftOperand: leftOperand ?? this.leftOperand,
      rightOperand: rightOperand ?? this.rightOperand,
      currentOperator: currentOperator ?? this.currentOperator,
      hasResult: hasResult ?? this.hasResult,
      isCalculatorMode: isCalculatorMode ?? this.isCalculatorMode,
      initialValue: initialValue,
    );
  }

  /// Форматирует число для отображения (убирает десятичные нули)
  static String formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(2);
    }
  }

  @override
  List<Object?> get props => [
    result,
    leftOperand,
    rightOperand,
    currentOperator,
    hasResult,
    isCalculatorMode,
  ];

  /// Вычисляет результат арифметической операции
  CalculatorState calculateResult(String text, {bool isEquals = false}) {
    // Если нет оператора, нечего вычислять
    if (currentOperator == CalculatorOperator.none) {
      return this;
    }

    // Получаем операнды из текста
    final parts = text.split(' ${currentOperator.symbol} ');
    if (parts.length < 2) {
      return this;
    }

    final leftText = parts[0].trim();
    final rightText = parts[1].trim();

    // Проверяем, что оба операнда являются числами
    final leftOperand = double.tryParse(leftText);
    if (leftOperand == null) {
      return this;
    }

    // Если правый операнд пуст или только минус, возвращаем текущее состояние
    if (rightText.isEmpty || rightText == '-') {
      return copyWith(result: text);
    }

    final parsedRight = double.tryParse(rightText);
    if (parsedRight == null) {
      return this;
    }

    final rightOperand = parsedRight;

    // Создаем выражение для вычисления
    final expression = '$leftOperand ${currentOperator.expressionSymbol} $rightOperand';

    // Парсим и вычисляем выражение
    double result;
    try {
      const evaluator = ExpressionEvaluator();
      final parsedExpression = Expression.parse(expression);
      result = evaluator.eval(parsedExpression, {}) as double;

      // Проверка деления на ноль
      if (currentOperator == CalculatorOperator.divide && rightOperand == 0) {
        result = leftOperand; // Если делим на ноль, сохраняем левый операнд
      }
    } on Object catch (_) {
      // В случае ошибки вычисления, возвращаем левый операнд
      result = leftOperand;
    }

    // Форматируем результат
    final formattedResult = CalculatorState.formatNumber(result);

    if (isEquals) {
      // Если нажата кнопка "=", обновляем выражение
      final resultDouble = double.tryParse(formattedResult);
      if (resultDouble == null) {
        return this;
      }

      // Проверяем, является ли число целым
      final isInteger = resultDouble == resultDouble.toInt();

      return copyWith(
        result: formattedResult,
        leftOperand: isInteger ? resultDouble.toInt().toDouble() : resultDouble,
        currentOperator: CalculatorOperator.none,
        hasResult: true,
      );
    } else {
      // Если это промежуточный расчет, сохраняем текущее выражение
      return copyWith(result: text, rightOperand: rightOperand, hasResult: false);
    }
  }
}
