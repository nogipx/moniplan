import 'package:flutter/material.dart';

import '../calculator_bloc/calculator_state.dart';

/// Константы для клавиатуры
class KeyboardConstants {
  /// Высота клавиатуры относительно экрана
  static const double keyboardHeightFactor = 0.8;

  /// Радиус скругления углов клавиатуры
  static const double keyboardBorderRadius = 20.0;

  /// Радиус скругления кнопок
  static const double buttonBorderRadius = 12.0;

  /// Стандартные отступы
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double tinyPadding = 4.0;

  /// Предустановленные суммы для быстрого ввода
  static const List<int> quickAmounts = [100, 500, 1000, 5000];
}

/// Тип клавиатуры для ввода
enum KeyboardType {
  /// Клавиатура для ввода суммы платежа
  amount,

  /// Клавиатура для ввода процента налога
  tax,
}

/// Модель для кнопки быстрого доступа
class QuickButton {
  /// Значение, которое будет передано в обработчик
  final double value;

  /// Текст, отображаемый на кнопке
  final String text;

  /// Цвет фона кнопки
  final Color? backgroundColor;

  /// Цвет текста кнопки
  final Color? textColor;

  /// Цвет границы кнопки
  final Color? borderColor;

  /// Пользовательский обработчик нажатия с доступом к состоянию калькулятора
  final Function(double value, CalculatorState state)? onPressed;

  /// Иконка (опционально)
  final IconData? icon;

  /// Создает модель кнопки быстрого доступа
  const QuickButton({
    required this.value,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.onPressed,
    this.icon,
  });

  /// Создает кнопку быстрого доступа с числовым значением
  factory QuickButton.fromValue({
    required double value,
    String? text,
    String suffix = '',
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    Function(double value, CalculatorState state)? onPressed,
    IconData? icon,
  }) {
    final displayValue = value.toInt() == value ? value.toInt().toString() : value.toString();
    return QuickButton(
      value: value,
      text: text ?? '$displayValue$suffix',
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      onPressed: onPressed,
      icon: icon,
    );
  }
}
