import 'package:flutter/material.dart';

/// Класс, представляющий цвета для различных состояний элементов интерфейса
///
/// Этот класс используется для хранения и управления цветами, которые
/// применяются для отображения состояний интерфейса, таких как ошибки,
/// предупреждения или инверсии акцентов. Включает в себя основные цвета для
/// ошибок и инверсии для лучшего выделения на различных фонах.
class StateColors {
  /// Цвет, обозначающий ошибки.
  ///
  /// Используется для текстов, иконок и других элементов, связанных с сообщениями об ошибках,
  /// чтобы выделить важные предупреждения и ошибки в интерфейсе.
  final Color error;

  /// Цвет контейнера для сообщений об ошибках, используется для выделения фона сообщений об ошибках.
  ///
  /// Применяется в качестве фона для карточек, всплывающих уведомлений или других элементов,
  /// которые сообщают об ошибке, для создания контраста и привлечения внимания.
  final Color errorContainer;

  /// Инверсированный основной цвет, используемый для выделения элементов на тёмных фонах.
  ///
  /// Используется для текстов или иконок на темных фонах, обеспечивая визуальный акцент,
  /// чтобы выделить ключевые элементы, такие как кнопки или ссылки.
  final Color inversePrimary;

  /// Создаёт класс набора цветов для состояний элементов
  ///
  /// Параметры:
  /// - [error]: Цвет, обозначающий ошибки.
  /// - [errorContainer]: Цвет контейнера для сообщений об ошибках.
  /// - [inversePrimary]: Инверсированный основной цвет для выделения на тёмных фонах.
  StateColors({
    required this.error,
    required this.errorContainer,
    required this.inversePrimary,
  });

  /// Набор цветов для [Brightness.dark]
  ///
  /// Используется для создания набора цветов, который лучше всего подходит для темной темы интерфейса.
  StateColors.dark()
      : error = const Color(0xFFCF6679),
        errorContainer = const Color(0xFFB00020),
        inversePrimary = const Color(0xFFBB86FC);

  /// Набор цветов для [Brightness.light]
  ///
  /// Используется для создания набора цветов, который лучше всего подходит для светлой темы интерфейса.
  StateColors.light()
      : error = const Color(0xFFB00020),
        errorContainer = const Color(0xFFFFDAD4),
        inversePrimary = const Color(0xFF6200EE);

  /// Интерполяция для анимированных переходов между [StateColors]
  ///
  /// Создаёт новую версию [StateColors], в которой цвета находятся на заданном
  /// проценте между текущим набором цветов и предоставленным [b] набором.
  ///
  /// Параметры:
  /// - [b]: Набор цветов, к которому выполняется интерполяция.
  /// - [t]: Позиция интерполяции, значение от 0.0 до 1.0, где 0.0 — это текущий набор,
  /// а 1.0 — это набор [b].
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
  ///
  /// Создаёт копию текущего объекта [StateColors], при этом можно задать
  /// изменения для некоторых из его полей. Поля, которые не переданы в качестве
  /// параметров, сохраняют свои текущие значения.
  ///
  /// Параметры:
  /// - [error]: Новый цвет для ошибок, если требуется изменить.
  /// - [errorContainer]: Новый цвет контейнера для сообщений об ошибках, если требуется изменить.
  /// - [inversePrimary]: Новый инверсированный основной цвет, если требуется изменить.
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
