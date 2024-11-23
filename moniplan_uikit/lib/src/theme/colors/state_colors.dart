import 'package:flutter/material.dart';

/// Класс, представляющий цвета для различных состояний элементов интерфейса
class StateColors {
  final Color active;
  final Color inactive;
  final Color error;
  final Color success;
  final Color warning;

  /// Создаёт приватный класс набора цветов для состояний элементов
  StateColors({
    required this.active,
    required this.inactive,
    required this.error,
    required this.success,
    required this.warning,
  });

  /// Набор цветов для [ThemeStyle.dark]
  StateColors.dark()
      : active = const Color(0xFF58A9E4),
        inactive = const Color(0xFF4F5D75),
        error = const Color(0xFFDF4A4A),
        success = const Color(0xFF4CAF50),
        warning = const Color(0xFFFFA500);

  /// Набор цветов для [ThemeStyle.light]
  StateColors.light()
      : active = const Color(0xFF0C82D8),
        inactive = const Color(0xFFB0BEC5),
        error = const Color(0xFFDF0000),
        success = const Color(0xFF3C8900),
        warning = const Color(0xFFFFD700);

  /// Интерполяция для анимированных переходов между [StateColors]
  StateColors lerp(StateColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return StateColors(
      active: Color.lerp(active, b?.active, t) ?? Colors.transparent,
      inactive: Color.lerp(inactive, b?.inactive, t) ?? Colors.transparent,
      error: Color.lerp(error, b?.error, t) ?? Colors.transparent,
      success: Color.lerp(success, b?.success, t) ?? Colors.transparent,
      warning: Color.lerp(warning, b?.warning, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [StateColors]
  StateColors copyWith({
    Color? active,
    Color? inactive,
    Color? error,
    Color? success,
    Color? warning,
  }) {
    return StateColors(
      active: active ?? this.active,
      inactive: inactive ?? this.inactive,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }
}
