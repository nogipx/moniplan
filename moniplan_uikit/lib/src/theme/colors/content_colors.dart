import 'package:flutter/material.dart';

/// Класс, представляющий цвета для контентных элементов интерфейса
///
/// Этот класс используется для хранения и управления цветами, которые
/// применяются для текстов, иконок и других контентных элементов, отображаемых
/// поверх различных фонов или акцентных элементов. Включает в себя цвета для
/// всех основных и второстепенных акцентных элементов, а также цвета для ошибок.
class ContentColors {
  /// Цвет текста и иконок поверх основного фона (background).
  ///
  /// Используется для текста и иконок, отображаемых поверх основного фона приложения,
  /// чтобы обеспечить читаемость и контраст.
  @Deprecated('Use onSurface instead.')
  final Color onBackground;

  /// Цвет текста и иконок поверх поверхности (surface).
  ///
  /// Применяется для текста и иконок, размещённых на поверхностях, таких как карточки
  /// или панели, для выделения информации на отдельных элементах.
  final Color onSurface;

  /// Цвет текста и иконок поверх альтернативной поверхности (surfaceVariant).
  ///
  /// Используется для текста и иконок на второстепенных поверхностях или декоративных
  /// элементах, где необходимо поддерживать более низкий контраст.
  final Color onSurfaceVariant;

  /// Цвет текста и иконок поверх инверсированной поверхности (inverseSurface).
  ///
  /// Применяется для текста и иконок, отображаемых поверх инверсированной поверхности,
  /// например, для всплывающих подсказок в тёмной теме, чтобы обеспечить контраст.
  final Color onInverseSurface;

  /// Цвет текста и иконок поверх основного акцента (primary).
  ///
  /// Используется для текста и иконок на элементах, которые имеют основной акцентный цвет,
  /// таких как кнопки, чтобы обеспечить хорошую читаемость на ярких цветах.
  final Color onPrimary;

  /// Цвет текста и иконок поверх второстепенного акцента (secondary).
  ///
  /// Используется для текста и иконок, которые размещены на элементах с второстепенным акцентом,
  /// например, на второстепенных кнопках или чипах.
  final Color onSecondary;

  /// Цвет текста и иконок поверх дополнительного акцента (tertiary).
  ///
  /// Применяется для текста и иконок, которые размещены на элементах с дополнительным акцентом,
  /// например, на декоративных деталях интерфейса.
  final Color onTertiary;

  /// Цвет текста и иконок поверх цвета ошибок (error).
  ///
  /// Используется для текста и иконок, связанных с сообщениями об ошибках или предупреждениями,
  /// чтобы выделить важную информацию и привлечь внимание пользователя.
  final Color onError;

  /// Создаёт класс набора цветов для контентных элементов
  ///
  /// Параметры:
  /// - [onBackground]: Цвет текста и иконок поверх основного фона.
  /// - [onSurface]: Цвет текста и иконок поверх поверхности.
  /// - [onSurfaceVariant]: Цвет текста и иконок поверх альтернативной поверхности.
  /// - [onInverseSurface]: Цвет текста и иконок поверх инверсированной поверхности.
  /// - [onPrimary]: Цвет текста и иконок поверх основного акцента.
  /// - [onSecondary]: Цвет текста и иконок поверх второстепенного акцента.
  /// - [onTertiary]: Цвет текста и иконок поверх дополнительного акцента.
  /// - [onError]: Цвет текста и иконок поверх цвета ошибок.
  ContentColors({
    required this.onBackground,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onInverseSurface,
    required this.onPrimary,
    required this.onSecondary,
    required this.onTertiary,
    required this.onError,
  });

  /// Набор цветов для [Brightness.dark]
  ///
  /// Используется для создания набора цветов, который лучше всего подходит для темной темы интерфейса.
  ContentColors.dark()
      : onBackground = const Color(0xFFFFFFFF),
        onSurface = const Color(0xFFE0E0E0),
        onSurfaceVariant = const Color(0xFFB0B0B0),
        onInverseSurface = const Color(0xFF121212),
        onPrimary = const Color(0xFF000000),
        onSecondary = const Color(0xFF000000),
        onTertiary = const Color(0xFF000000),
        onError = const Color(0xFFFFFFFF);

  /// Набор цветов для [Brightness.light]
  ///
  /// Используется для создания набора цветов, который лучше всего подходит для светлой темы интерфейса.
  ContentColors.light()
      : onBackground = const Color(0xFF000000),
        onSurface = const Color(0xFF121212),
        onSurfaceVariant = const Color(0xFF2C2C2C),
        onInverseSurface = const Color(0xFFFFFFFF),
        onPrimary = const Color(0xFFFFFFFF),
        onSecondary = const Color(0xFFFFFFFF),
        onTertiary = const Color(0xFFFFFFFF),
        onError = const Color(0xFF000000);

  /// Интерполяция для анимированных переходов между [ContentColors]
  ///
  /// Создаёт новую версию [ContentColors], в которой цвета находятся на заданном
  /// проценте между текущим набором цветов и предоставленным [b] набором.
  ///
  /// Параметры:
  /// - [b]: Набор цветов, к которому выполняется интерполяция.
  /// - [t]: Позиция интерполяции, значение от 0.0 до 1.0, где 0.0 — это текущий набор,
  /// а 1.0 — это набор [b].
  ContentColors lerp(ContentColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return ContentColors(
      onBackground: Color.lerp(onBackground, b?.onBackground, t) ?? Colors.transparent,
      onSurface: Color.lerp(onSurface, b?.onSurface, t) ?? Colors.transparent,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, b?.onSurfaceVariant, t) ?? Colors.transparent,
      onInverseSurface: Color.lerp(onInverseSurface, b?.onInverseSurface, t) ?? Colors.transparent,
      onPrimary: Color.lerp(onPrimary, b?.onPrimary, t) ?? Colors.transparent,
      onSecondary: Color.lerp(onSecondary, b?.onSecondary, t) ?? Colors.transparent,
      onTertiary: Color.lerp(onTertiary, b?.onTertiary, t) ?? Colors.transparent,
      onError: Color.lerp(onError, b?.onError, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [ContentColors]
  ///
  /// Создаёт копию текущего объекта [ContentColors], при этом можно задать
  /// изменения для некоторых из его полей. Поля, которые не переданы в качестве
  /// параметров, сохраняют свои текущие значения.
  ///
  /// Параметры:
  /// - [onBackground]: Новый цвет текста и иконок поверх основного фона, если требуется изменить.
  /// - [onSurface]: Новый цвет текста и иконок поверх поверхности, если требуется изменить.
  /// - [onSurfaceVariant]: Новый цвет текста и иконок поверх альтернативной поверхности, если требуется изменить.
  /// - [onInverseSurface]: Новый цвет текста и иконок поверх инверсированной поверхности, если требуется изменить.
  /// - [onPrimary]: Новый цвет текста и иконок поверх основного акцента, если требуется изменить.
  /// - [onSecondary]: Новый цвет текста и иконок поверх второстепенного акцента, если требуется изменить.
  /// - [onTertiary]: Новый цвет текста и иконок поверх дополнительного акцента, если требуется изменить.
  /// - [onError]: Новый цвет текста и иконок поверх цвета ошибок, если требуется изменить.
  ContentColors copyWith({
    Color? onBackground,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? onInverseSurface,
    Color? onPrimary,
    Color? onSecondary,
    Color? onTertiary,
    Color? onError,
  }) {
    return ContentColors(
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onTertiary: onTertiary ?? this.onTertiary,
      onError: onError ?? this.onError,
    );
  }
}
