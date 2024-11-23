import 'package:flutter/material.dart';

/// Класс, представляющий цвета для различных состояний элементов интерфейса
class StateColors {
  final Color error;
  final Color errorContainer;
  final Color inversePrimary;

  /// Создаёт приватный класс набора цветов для состояний элементов
  StateColors({
    required this.error,
    required this.errorContainer,
    required this.inversePrimary,
  });

  /// Набор цветов для [Brightness.dark]
  StateColors.dark()
      : error = const Color(0xFFCF6679),
        errorContainer = const Color(0xFFB00020),
        inversePrimary = const Color(0xFFBB86FC);

  /// Набор цветов для [Brightness.light]
  StateColors.light()
      : error = const Color(0xFFB00020),
        errorContainer = const Color(0xFFFFDAD4),
        inversePrimary = const Color(0xFF6200EE);

  /// Интерполяция для анимированных переходов между [StateColors]
  StateColors lerp(StateColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return StateColors(
      error: Color.lerp(error, b?.error, t) ?? Colors.transparent,
      errorContainer: Color.lerp(errorContainer, b?.errorContainer, t) ?? Colors.transparent,
      inversePrimary: Color.lerp(inversePrimary, b?.inversePrimary, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [StateColors]
  StateColors copyWith({
    Color? error,
    Color? errorContainer,
    Color? inversePrimary,
  }) {
    return StateColors(
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      inversePrimary: inversePrimary ?? this.inversePrimary,
    );
  }
}
