import 'package:flutter/material.dart';

/// Класс, представляющий цвета фонов для интерфейса
///
/// Этот класс используется для хранения и управления цветами, которые
/// применяются в качестве фонов для различных элементов интерфейса, таких как
/// основное фоновое пространство, поверхности карточек, панелей и другие
/// элементы. Включает в себя также инверсированный цвет поверхности для
/// различных случаев использования.
class BackgroundColors {
  /// Основной цвет фона приложения.
  ///
  /// Применяется для основного фона всего приложения, обеспечивая базовый
  /// цвет, который влияет на общее восприятие интерфейса.
  final Color background;

  /// Цвет поверхности, используемый для карточек, панелей и модальных окон.
  ///
  /// Этот цвет используется для таких элементов, как карточки, модальные окна,
  /// панели, обеспечивая контраст с основным фоном и выделяя данные элементы.
  final Color surface;

  /// Альтернативный цвет поверхности, используемый для второстепенных слоёв или декоративных элементов.
  ///
  /// Применяется для менее важных слоёв или декоративных элементов, таких как
  /// карточки с дополнительной информацией или декоративные панели.
  final Color surfaceVariant;

  /// Инверсированный цвет поверхности, используется, например, для всплывающих подсказок в тёмной теме.
  ///
  /// Часто используется для всплывающих подсказок, выделения кнопок на темных
  /// фонах или при необходимости создания контрастных элементов на основном фоне.
  final Color inverseSurface;

  /// Создаёт приватный класс набора цветов для фонов
  ///
  /// Параметры:
  /// - [background]: Основной цвет фона.
  /// - [surface]: Цвет поверхности для карточек, панелей и модальных окон.
  /// - [surfaceVariant]: Альтернативный цвет поверхности.
  /// - [inverseSurface]: Инверсированный цвет поверхности.
  BackgroundColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.inverseSurface,
  });

  /// Набор цветов для [Brightness.dark]
  ///
  /// Используется для создания набора цветов, который лучше всего подходит для темной темы интерфейса.
  BackgroundColors.dark()
      : background = const Color(0xFF121212),
        surface = const Color(0xFF1E1E1E),
        surfaceVariant = const Color(0xFF2C2C2C),
        inverseSurface = const Color(0xFFF1F1F1);

  /// Набор цветов для [Brightness.light]
  ///
  /// Используется для создания набора цветов, который лучше всего подходит для светлой темы интерфейса.
  BackgroundColors.light()
      : background = const Color(0xFFFFFFFF),
        surface = const Color(0xFFF1F1F1),
        surfaceVariant = const Color(0xFFEAEAEA),
        inverseSurface = const Color(0xFF2C2C2C);

  /// Интерполяция для анимированных переходов между [BackgroundColors]
  ///
  /// Создаёт новую версию [BackgroundColors], в которой цвета находятся на заданном
  /// проценте между текущим набором цветов и предоставленным [b] набором.
  ///
  /// Параметры:
  /// - [b]: Набор цветов, к которому выполняется интерполяция.
  /// - [t]: Позиция интерполяции, значение от 0.0 до 1.0, где 0.0 — это текущий набор,
  /// а 1.0 — это набор [b].
  BackgroundColors lerp(BackgroundColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return BackgroundColors(
      background: Color.lerp(background, b?.background, t) ?? Colors.transparent,
      surface: Color.lerp(surface, b?.surface, t) ?? Colors.transparent,
      surfaceVariant: Color.lerp(surfaceVariant, b?.surfaceVariant, t) ?? Colors.transparent,
      inverseSurface: Color.lerp(inverseSurface, b?.inverseSurface, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [BackgroundColors]
  ///
  /// Создаёт копию текущего объекта [BackgroundColors], при этом можно задать
  /// изменения для некоторых из его полей. Поля, которые не переданы в качестве
  /// параметров, сохраняют свои текущие значения.
  ///
  /// Параметры:
  /// - [background]: Новый основной цвет фона, если требуется изменить.
  /// - [surface]: Новый цвет поверхности, если требуется изменить.
  /// - [surfaceVariant]: Новый альтернативный цвет поверхности, если требуется изменить.
  /// - [inverseSurface]: Новый инверсированный цвет поверхности, если требуется изменить.
  BackgroundColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? inverseSurface,
  }) {
    return BackgroundColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
    );
  }
}
