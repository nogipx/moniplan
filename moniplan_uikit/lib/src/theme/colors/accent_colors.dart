import 'package:flutter/material.dart';

/// Класс, представляющий цвета для акцентных элементов интерфейса
///
/// Этот класс используется для хранения и управления цветами, которые
/// применяются для акцентных элементов интерфейса, таких как кнопки, выделения,
/// интерактивные элементы и другие декоративные детали. Включает в себя цвета
/// для основных, второстепенных и дополнительных акцентов, а также их контейнеры.
class AccentColors {
  /// Основной акцентный цвет, используемый для основных интерактивных элементов,
  /// таких как кнопки и выделения.
  ///
  /// Используется для выделения главных интерактивных элементов, привлекающих
  /// внимание пользователя и стимулирующих взаимодействие с интерфейсом.
  final Color primary;

  /// Цвет контейнера для основного акцента. Этот цвет используется как фоновый
  /// цвет для элементов, которые содержат основной акцент, например, для кнопок или карточек.
  ///
  /// Может применяться для создания контрастного фона для кнопок, карточек или
  /// других компонентов, содержащих основной акцент.
  final Color primaryContainer;

  /// Второстепенный акцентный цвет, используемый для элементов, которые требуют
  /// меньшего визуального акцента, таких как второстепенные кнопки или чипы.
  ///
  /// Этот цвет подходит для второстепенных действий или элементов, которые не
  /// требуют основного внимания, но всё ещё должны быть заметны.
  final Color secondary;

  /// Цвет контейнера для второстепенного акцента. Применяется для фона элементов,
  /// которые используют второстепенный акцент.
  ///
  /// Используется для создания контрастного фона для второстепенных элементов,
  /// таких как чипы, дополнительные кнопки и элементы, которые поддерживают основной контент.
  final Color secondaryContainer;

  /// Дополнительный акцентный цвет, обычно используется для декоративных элементов
  /// или акцентирования менее важных деталей.
  ///
  /// Применяется для дополнительных декоративных деталей, создающих визуальную
  /// привлекательность, но не требующих главного внимания пользователя.
  final Color tertiary;

  /// Цвет контейнера для дополнительного акцента. Используется для фона
  /// декоративных элементов, которые содержат дополнительный акцент.
  ///
  /// Используется для создания контраста в фоновом цвете для декоративных элементов,
  /// таких как иконки или вспомогательные карточки.
  final Color tertiaryContainer;

  /// Создаёт класс набора акцентных цветов
  ///
  /// Параметры:
  /// - [primary]: Основной акцентный цвет.
  /// - [primaryContainer]: Цвет контейнера для основного акцента.
  /// - [secondary]: Второстепенный акцентный цвет.
  /// - [secondaryContainer]: Цвет контейнера для второстепенного акцента.
  /// - [tertiary]: Дополнительный акцентный цвет.
  /// - [tertiaryContainer]: Цвет контейнера для дополнительного акцента.
  AccentColors({
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.tertiary,
    required this.tertiaryContainer,
  });

  /// Набор акцентных цветов для [Brightness.dark]
  ///
  /// Используется для создания набора акцентных цветов, который лучше всего
  /// подходит для темной темы интерфейса. Эти цвета обеспечивают хорошую видимость
  /// и контрастность в условиях низкой освещенности.
  AccentColors.dark()
      : primary = const Color(0xFFBB86FC),
        primaryContainer = const Color(0xFF3700B3),
        secondary = const Color(0xFF03DAC6),
        secondaryContainer = const Color(0xFF018786),
        tertiary = const Color(0xFFCF6679),
        tertiaryContainer = const Color(0xFFB00020);

  /// Набор акцентных цветов для [Brightness.light]
  ///
  /// Используется для создания набора акцентных цветов, который лучше всего
  /// подходит для светлой темы интерфейса. Эти цвета обеспечивают яркость и
  /// контрастность при ярком освещении.
  AccentColors.light()
      : primary = const Color(0xFF6200EE),
        primaryContainer = const Color(0xFFBB86FC),
        secondary = const Color(0xFF03DAC6),
        secondaryContainer = const Color(0xFF018786),
        tertiary = const Color(0xFFB00020),
        tertiaryContainer = const Color(0xFFCF6679);

  /// Интерполяция для анимированных переходов между [AccentColors]
  ///
  /// Создаёт новую версию [AccentColors], в которой цвета находятся на заданном
  /// проценте между текущим набором цветов и предоставленным [b] набором.
  ///
  /// Параметры:
  /// - [b]: Набор цветов, к которому выполняется интерполяция.
  /// - [t]: Позиция интерполяции, значение от 0.0 до 1.0, где 0.0 — это текущий набор,
  /// а 1.0 — это набор [b].
  AccentColors lerp(AccentColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AccentColors(
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      primaryContainer: Color.lerp(primaryContainer, b?.primaryContainer, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      secondaryContainer:
          Color.lerp(secondaryContainer, b?.secondaryContainer, t) ?? Colors.transparent,
      tertiary: Color.lerp(tertiary, b?.tertiary, t) ?? Colors.transparent,
      tertiaryContainer:
          Color.lerp(tertiaryContainer, b?.tertiaryContainer, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [AccentColors]
  ///
  /// Создаёт копию текущего объекта [AccentColors], при этом можно задать
  /// изменения для некоторых из его полей. Поля, которые не переданы в качестве
  /// параметров, сохраняют свои текущие значения.
  ///
  /// Параметры:
  /// - [primary]: Новый основной акцентный цвет, если требуется изменить.
  /// - [primaryContainer]: Новый цвет контейнера для основного акцента, если требуется изменить.
  /// - [secondary]: Новый второстепенный акцентный цвет, если требуется изменить.
  /// - [secondaryContainer]: Новый цвет контейнера для второстепенного акцента, если требуется изменить.
  /// - [tertiary]: Новый дополнительный акцентный цвет, если требуется изменить.
  /// - [tertiaryContainer]: Новый цвет контейнера для дополнительного акцента, если требуется изменить.
  AccentColors copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? secondary,
    Color? secondaryContainer,
    Color? tertiary,
    Color? tertiaryContainer,
  }) {
    return AccentColors(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
    );
  }
}
