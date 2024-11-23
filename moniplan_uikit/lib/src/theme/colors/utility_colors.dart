import 'package:flutter/material.dart';

/// Класс, представляющий цвета для утилитарных элементов интерфейса
///
/// Этот класс используется для хранения и управления цветами, которые
/// применяются для различных утилитарных элементов, таких как границы, тени,
/// затемнения модальных окон и другие элементы, добавляющие визуальную глубину
/// и акцент к интерфейсу.
class UtilityColors {
  /// Цвет границ или разделителей.
  ///
  /// Используется для различных элементов, таких как границы карточек, линии разделения
  /// между элементами или декоративные разделители для повышения визуальной структуры интерфейса.
  final Color outline;

  /// Альтернативный цвет для границ, используется для создания дополнительного
  /// контраста в разделителях или декоративных элементах.
  ///
  /// Применяется в случаях, когда требуется создать визуальное различие между
  /// основными и второстепенными границами, чтобы улучшить восприятие интерфейса.
  final Color outlineVariant;

  /// Цвет теней, используемых для создания глубины и выделения элементов интерфейса.
  ///
  /// Используется для придания объема и глубины элементам интерфейса, таким как кнопки,
  /// карточки и модальные окна, чтобы они выглядели более естественными и выделялись на фоне.
  final Color shadow;

  /// Цвет затемнения (scrim), используемый для фонов модальных окон или блокирующих слоёв.
  ///
  /// Применяется в фонах модальных окон или блокирующих слоев, чтобы привлечь внимание к
  /// активному элементу и затемнить остальную часть интерфейса.
  final Color scrim;

  /// Цвет оттенков поверхности при взаимодействии, например, при наведении или нажатии.
  ///
  /// Используется для создания визуальной обратной связи на интерактивных элементах,
  /// таких как кнопки или карточки, когда пользователь наводит или нажимает на них,
  /// что помогает указать на доступность элемента для взаимодействия.
  final Color surfaceTint;

  /// Создаёт класс набора цветов для утилитарных элементов
  ///
  /// Параметры:
  /// - [outline]: Цвет границ или разделителей.
  /// - [outlineVariant]: Альтернативный цвет для границ.
  /// - [shadow]: Цвет теней, используемых для создания глубины.
  /// - [scrim]: Цвет затемнения для модальных окон или блокирующих слоёв.
  /// - [surfaceTint]: Цвет оттенков поверхности при взаимодействии.
  UtilityColors({
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.surfaceTint,
  });

  /// Набор цветов для [Brightness.dark]
  ///
  /// Используется для создания набора цветов, который лучше всего подходит для темной темы интерфейса.
  UtilityColors.dark()
      : outline = const Color(0xFFB0BEC5),
        outlineVariant = const Color(0xFF8C9EAF),
        shadow = const Color(0xFF000000),
        scrim = const Color(0xFF121212),
        surfaceTint = const Color(0xFFBB86FC);

  /// Набор цветов для [Brightness.light]
  ///
  /// Используется для создания набора цветов, который лучше всего подходит для светлой темы интерфейса.
  UtilityColors.light()
      : outline = const Color(0xFF757575),
        outlineVariant = const Color(0xFFB0BEC5),
        shadow = const Color(0xFF000000),
        scrim = const Color(0xFF000000),
        surfaceTint = const Color(0xFF6200EE);

  /// Интерполяция для анимированных переходов между [UtilityColors]
  ///
  /// Создаёт новую версию [UtilityColors], в которой цвета находятся на заданном
  /// проценте между текущим набором цветов и предоставленным [b] набором.
  ///
  /// Параметры:
  /// - [b]: Набор цветов, к которому выполняется интерполяция.
  /// - [t]: Позиция интерполяции, значение от 0.0 до 1.0, где 0.0 — это текущий набор,
  /// а 1.0 — это набор [b].
  UtilityColors lerp(UtilityColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return UtilityColors(
      outline: Color.lerp(outline, b?.outline, t) ?? Colors.transparent,
      outlineVariant: Color.lerp(outlineVariant, b?.outlineVariant, t) ?? Colors.transparent,
      shadow: Color.lerp(shadow, b?.shadow, t) ?? Colors.transparent,
      scrim: Color.lerp(scrim, b?.scrim, t) ?? Colors.transparent,
      surfaceTint: Color.lerp(surfaceTint, b?.surfaceTint, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [UtilityColors]
  ///
  /// Создаёт копию текущего объекта [UtilityColors], при этом можно задать
  /// изменения для некоторых из его полей. Поля, которые не переданы в качестве
  /// параметров, сохраняют свои текущие значения.
  ///
  /// Параметры:
  /// - [outline]: Новый цвет для границ или разделителей, если требуется изменить.
  /// - [outlineVariant]: Новый альтернативный цвет для границ, если требуется изменить.
  /// - [shadow]: Новый цвет теней, если требуется изменить.
  /// - [scrim]: Новый цвет затемнения для модальных окон, если требуется изменить.
  /// - [surfaceTint]: Новый цвет оттенков поверхности, если требуется изменить.
  UtilityColors copyWith({
    Color? outline,
    Color? outlineVariant,
    Color? shadow,
    Color? scrim,
    Color? surfaceTint,
  }) {
    return UtilityColors(
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
      surfaceTint: surfaceTint ?? this.surfaceTint,
    );
  }
}
