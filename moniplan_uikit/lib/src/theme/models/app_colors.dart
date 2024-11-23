import 'package:flutter/material.dart';
import 'package:moniplan_uikit/src/theme/_index.dart';

/// Класс набора цветов для ui kit
class AppColors {
  final ColorScheme scheme;
  final BackgroundColors background;
  final ButtonColors button;
  final ElementColors element;
  final StateColors state;
  final TextColors text;

  /// Создаёт приватный класс набора цветов для ui kit
  const AppColors({
    required this.scheme,
    required this.background,
    required this.button,
    required this.element,
    required this.state,
    required this.text,
  });

  /// Набор цветов для [ThemeStyle.dark]
  AppColors.dark()
      : scheme = ColorScheme.dark(),
        background = BackgroundColors.dark(),
        button = ButtonColors.dark(),
        element = ElementColors.dark(),
        state = StateColors.dark(),
        text = TextColors.dark();

  /// Набор цветов для [ThemeStyle.light]
  AppColors.light()
      : scheme = ColorScheme.light(),
        background = BackgroundColors.light(),
        button = ButtonColors.light(),
        element = ElementColors.light(),
        state = StateColors.light(),
        text = TextColors.light();

  /// Интерполяция для анимированных переходов между [AppColors]
  AppColors lerp(AppColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppColors(
      scheme: scheme.lerp(b?.scheme, t),
      background: background.lerp(b?.background, t),
      button: button.lerp(b?.button, t),
      element: element.lerp(b?.element, t),
      state: state.lerp(b?.state, t),
      text: text.lerp(b?.text, t),
    );
  }

  /// Метод копирования [AppColors]
  AppColors copyWith({
    ColorScheme? scheme,
    BackgroundColors? background,
    ButtonColors? button,
    ElementColors? element,
    StateColors? state,
    TextColors? text,
  }) {
    return AppColors(
      scheme: scheme ?? this.scheme,
      background: background ?? this.background,
      button: button ?? this.button,
      element: element ?? this.element,
      state: state ?? this.state,
      text: text ?? this.text,
    );
  }

  /// Получение [AppColors] по [themeStyle]
  static AppColors get(ThemeStyle themeStyle) => switch (themeStyle) {
        ThemeStyle.light => AppColors.light(),
        _ => AppColors.dark(),
      };

  factory AppColors.fromColorScheme(ColorScheme colorScheme) {
    return AppColors(
      scheme: colorScheme,
      background: BackgroundColors(
        primary: colorScheme.background,
        secondary: colorScheme.surface,
        tertiary: colorScheme.onPrimary,
        appBar: colorScheme.primary,
        drawer: colorScheme.onSecondary,
        bottomNav: colorScheme.secondary,
      ),
      text: TextColors(
        primary: colorScheme.onBackground,
        secondary: colorScheme.onSurface,
        accent: colorScheme.onPrimary,
        disabled: colorScheme.onSecondary.withOpacity(0.38),
        hint: colorScheme.onSurface.withOpacity(0.6),
        inverse: colorScheme.onBackground,
        error: colorScheme.onError,
      ),
      button: ButtonColors(
        primary: colorScheme.primary,
        secondary: colorScheme.secondary,
        tertiary: colorScheme.tertiary,
        pressed: colorScheme.onPrimary,
        hovered: colorScheme.onSecondary,
        disabled: colorScheme.onSurface.withOpacity(0.12),
        overlay: colorScheme.primary.withOpacity(0.08),
      ),
      element: ElementColors(
        card: colorScheme.surface,
        modal: colorScheme.background,
        border: colorScheme.outline,
        shadow: Colors.black.withOpacity(0.1),
        divider: colorScheme.onSurface.withOpacity(0.12),
        highlight: colorScheme.primary.withOpacity(0.15),
        background: colorScheme.background,
      ),
      state: StateColors(
        active: colorScheme.primary,
        inactive: colorScheme.onSurface.withOpacity(0.5),
        error: colorScheme.error,
        success: Colors.green, // Заменить на цвет успеха из палитры
        warning: Colors.orange, // Заменить на цвет предупреждения из палитры
      ),
    );
  }
}

extension ColorSchemeLerp on ColorScheme {
  ColorScheme lerp(ColorScheme? b, double t) {
    return ColorScheme(
      primary: Color.lerp(primary, b?.primary, t)!,
      onPrimary: Color.lerp(onPrimary, b?.onPrimary, t)!,
      secondary: Color.lerp(secondary, b?.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, b?.onSecondary, t)!,
      surface: Color.lerp(surface, b?.surface, t)!,
      onSurface: Color.lerp(onSurface, b?.onSurface, t)!,
      background: Color.lerp(background, b?.background, t)!,
      onBackground: Color.lerp(onBackground, b?.onBackground, t)!,
      error: Color.lerp(error, b?.error, t)!,
      onError: Color.lerp(onError, b?.onError, t)!,
      brightness: t < 0.5 ? brightness : b?.brightness ?? brightness,
    );
  }
}
