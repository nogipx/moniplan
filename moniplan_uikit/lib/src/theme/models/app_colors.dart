import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class AppColors {
  final ColorScheme scheme;
  final BackgroundColors background;
  final TextColors text;
  final ButtonColors button;
  final ElementColors element;
  final StateColors state;

  Brightness get brightness => scheme.brightness;

  AppColors({
    required this.scheme,
    required this.background,
    required this.text,
    required this.button,
    required this.element,
    required this.state,
  });

  /// Набор цветов для [Brightness.dark]
  AppColors.dark()
      : scheme = ColorScheme.dark(),
        background = BackgroundColors.dark(),
        button = ButtonColors.dark(),
        element = ElementColors.dark(),
        state = StateColors.dark(),
        text = TextColors.dark();

  /// Набор цветов для [Brightness.light]
  AppColors.light()
      : scheme = ColorScheme.light(),
        background = BackgroundColors.light(),
        button = ButtonColors.light(),
        element = ElementColors.light(),
        state = StateColors.light(),
        text = TextColors.light();

  static AppColors get(Brightness _) => switch (_) {
        Brightness.light => AppColors.light(),
        _ => AppColors.dark(),
      };

  /// Интерполяция для анимированных переходов между [AppColors]
  AppColors lerp(AppColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppColors(
      scheme: ColorSchemeLerp(scheme).lerp(b?.scheme, t),
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

  static AppColors fromSeedColor({
    required Color seedColor,
    required bool isDarkTheme,
  }) {
    final int seedColorArgb = seedColor.value;

    // Генерация палитры через CorePalette
    final CorePalette corePalette = CorePalette.of(seedColorArgb);
    final brightness = isDarkTheme ? Brightness.dark : Brightness.light;

    // Тональные палитры
    final TonalPalette primaryPalette = corePalette.primary;
    final TonalPalette secondaryPalette = corePalette.secondary;
    final TonalPalette tertiaryPalette = corePalette.tertiary;
    final TonalPalette neutralPalette = corePalette.neutral;
    final TonalPalette neutralVariantPalette = corePalette.neutralVariant;
    final TonalPalette errorPalette = corePalette.error;

    // Определение тонов
    final bool isLight = brightness == Brightness.light;
    final int primaryTone = isLight ? 40 : 80;
    final int onPrimaryTone = isLight ? 100 : 20;
    final int primaryContainerTone = isLight ? 90 : 30;
    final int onPrimaryContainerTone = isLight ? 10 : 90;

    final int surfaceTone = isLight ? 99 : 10;
    final int onSurfaceTone = isLight ? 10 : 90;

    final int outlineTone = isLight ? 50 : 60;

    // Создание ColorScheme
    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: Color(primaryPalette.get(primaryTone)),
      onPrimary: Color(primaryPalette.get(onPrimaryTone)),
      primaryContainer: Color(primaryPalette.get(primaryContainerTone)),
      onPrimaryContainer: Color(primaryPalette.get(onPrimaryContainerTone)),
      secondary: Color(secondaryPalette.get(primaryTone)),
      onSecondary: Color(secondaryPalette.get(onPrimaryTone)),
      secondaryContainer: Color(secondaryPalette.get(primaryContainerTone)),
      onSecondaryContainer: Color(secondaryPalette.get(onPrimaryContainerTone)),
      tertiary: Color(tertiaryPalette.get(primaryTone)),
      onTertiary: Color(tertiaryPalette.get(onPrimaryTone)),
      tertiaryContainer: Color(tertiaryPalette.get(primaryContainerTone)),
      onTertiaryContainer: Color(tertiaryPalette.get(onPrimaryContainerTone)),
      error: Color(errorPalette.get(primaryTone)),
      onError: Color(errorPalette.get(onPrimaryTone)),
      errorContainer: Color(errorPalette.get(primaryContainerTone)),
      onErrorContainer: Color(errorPalette.get(onPrimaryContainerTone)),
      surface: Color(neutralPalette.get(surfaceTone)),
      onSurface: Color(neutralPalette.get(onSurfaceTone)),
      onSurfaceVariant: Color(neutralVariantPalette.get(outlineTone)),
      outline: Color(neutralVariantPalette.get(outlineTone)),
      shadow: Colors.black,
      inverseSurface: Color(neutralPalette.get(onSurfaceTone)),
      onInverseSurface: Color(neutralPalette.get(surfaceTone)),
      inversePrimary: Color(primaryPalette.get(onPrimaryTone)),
      surfaceTint: Color(primaryPalette.get(primaryTone)),
    );

    return fromColorScheme(colorScheme);
  }

  static AppColors fromColorScheme(ColorScheme colorScheme) {
    return AppColors(
      scheme: colorScheme,
      background: BackgroundColors(
        primary: colorScheme.surface,
        secondary: colorScheme.surfaceDim,
        tertiary: colorScheme.tertiaryContainer,
        appBar: colorScheme.primary,
        drawer: colorScheme.secondaryContainer,
        bottomNav: colorScheme.surface,
      ),
      text: TextColors(
        primary: colorScheme.surface,
        secondary: colorScheme.onSurface,
        accent: colorScheme.primary,
        disabled: colorScheme.onSurface.withOpacity(0.38),
        hint: colorScheme.onSurface.withOpacity(0.6),
        inverse: colorScheme.onPrimary,
        error: colorScheme.onError,
      ),
      button: ButtonColors(
        primary: colorScheme.primary,
        secondary: colorScheme.secondary,
        tertiary: colorScheme.tertiary,
        pressed: colorScheme.onPrimary.withOpacity(0.12),
        hovered: colorScheme.primaryContainer,
        disabled: colorScheme.onSurface.withOpacity(0.12),
        overlay: colorScheme.primary.withOpacity(0.08),
      ),
      element: ElementColors(
        card: colorScheme.surface,
        modal: colorScheme.tertiaryContainer,
        border: colorScheme.outline,
        shadow: Colors.black.withOpacity(0.2),
        divider: colorScheme.outline.withOpacity(0.5),
        highlight: colorScheme.primary.withOpacity(0.1),
        background: colorScheme.tertiaryContainer,
      ),
      state: StateColors(
        active: colorScheme.primary,
        inactive: colorScheme.onSurface.withOpacity(0.5),
        error: colorScheme.error,
        success: Colors.green, // Успех можно динамически настроить
        warning: Colors.orange, // Предупреждение можно динамически настроить
      ),
    );
  }
}
