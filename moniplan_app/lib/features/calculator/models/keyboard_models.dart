import 'package:flutter/material.dart';

import '../bloc/calculator_state.dart';

/// Константы для клавиатуры
class KeyboardConstants {
  /// Высота клавиатуры относительно экрана
  static const double keyboardHeightFactor = 0.8;

  /// Радиус скругления углов клавиатуры
  static const double keyboardBorderRadius = 20;

  /// Радиус скругления кнопок
  static const double buttonBorderRadius = 12;

  /// Стандартные отступы
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double tinyPadding = 4;
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
  /// Текст, отображаемый на кнопке
  final String text;

  /// Цвет фона кнопки
  final Color? backgroundColor;

  /// Цвет текста кнопки
  final Color? textColor;

  /// Цвет границы кнопки
  final Color? borderColor;

  /// Пользовательский обработчик нажатия с доступом к состоянию калькулятора
  final ValueChanged<CalculatorState>? onPressed;

  /// Иконка (опционально)
  final IconData? icon;

  /// Создает модель кнопки быстрого доступа
  const QuickButton({
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
    Function(CalculatorState state)? onPressed,
    IconData? icon,
  }) {
    final displayValue = value.toInt() == value ? value.toInt().toString() : value.toString();
    return QuickButton(
      text: text ?? '$displayValue$suffix',
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      onPressed: onPressed,
      icon: icon,
    );
  }
}
