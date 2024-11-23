import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class AppColors {
  final ColorScheme scheme;
  final AccentColors accent;
  final BackgroundColors background;
  final ContentColors content;
  final StateColors state;
  final UtilityColors util;

  Brightness get brightness => scheme.brightness;

  AppColors({
    required this.scheme,
    required this.accent,
    required this.background,
    required this.content,
    required this.state,
    required this.util,
  });

  /// Набор цветов для [Brightness.dark]
  AppColors.dark()
      : scheme = ColorScheme.dark(),
        accent = AccentColors.dark(),
        background = BackgroundColors.dark(),
        content = ContentColors.dark(),
        state = StateColors.dark(),
        util = UtilityColors.dark();

  /// Набор цветов для [Brightness.light]
  AppColors.light()
      : scheme = ColorScheme.light(),
        accent = AccentColors.light(),
        background = BackgroundColors.light(),
        content = ContentColors.light(),
        state = StateColors.light(),
        util = UtilityColors.light();

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
      accent: accent.lerp(b?.accent, t),
      background: background.lerp(b?.background, t),
      content: content.lerp(b?.content, t),
      state: state.lerp(b?.state, t),
      util: util.lerp(b?.util, t),
    );
  }

  /// Метод копирования [AppColors]
  AppColors copyWith({
    ColorScheme? scheme,
    AccentColors? accent,
    BackgroundColors? background,
    ContentColors? content,
    StateColors? state,
    UtilityColors? util,
  }) {
    return AppColors(
      scheme: scheme ?? this.scheme,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      content: content ?? this.content,
      state: state ?? this.state,
      util: util ?? this.util,
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
      outline: Color(neutralVariantPalette.get(outlineTone)),
      shadow: Colors.black,
      inverseSurface: Color(neutralPalette.get(onSurfaceTone)),
      onInverseSurface: Color(neutralPalette.get(surfaceTone)),
      inversePrimary: Color(primaryPalette.get(onPrimaryTone)),
      surfaceTint: Color(primaryPalette.get(primaryTone)),
      outlineVariant: Color(neutralVariantPalette.get(outlineTone)),
      scrim: Colors.black.withOpacity(0.5),
    );

    return fromColorScheme(colorScheme);
  }

  static AppColors fromColorScheme(ColorScheme colorScheme) {
    return AppColors(
      scheme: colorScheme,
      accent: AccentColors(
        /// Основной акцентный цвет для кнопок и выделений
        primary: colorScheme.primary,

        /// Контейнер для основного акцента, например, фон кнопок или карточек
        primaryContainer: colorScheme.primaryContainer,

        /// Второстепенный акцентный цвет, используется для менее выделенных кнопок или чипов
        secondary: colorScheme.secondary,

        /// Контейнер для второстепенного акцента
        secondaryContainer: colorScheme.secondaryContainer,

        /// Дополнительный акцентный цвет, например, для декоративных элементов
        tertiary: colorScheme.tertiary,

        /// Контейнер для дополнительного акцента
        tertiaryContainer: colorScheme.tertiaryContainer,
      ),
      background: BackgroundColors(
        /// Основной цвет фона приложения
        background: colorScheme.onBackground,

        /// Цвет поверхности для карточек, панелей и модальных окон
        surface: colorScheme.surface,

        /// Альтернативный цвет поверхности для второстепенных слоёв или декоративных элементов
        surfaceVariant: colorScheme.surfaceVariant,

        /// Инверсированный цвет поверхности, например, для всплывающих подсказок в тёмной теме
        inverseSurface: colorScheme.inverseSurface,
      ),
      content: ContentColors(
        /// Цвет текста и иконок поверх основного фона
        onBackground: colorScheme.onBackground,

        /// Цвет текста и иконок поверх поверхности (surface)
        onSurface: colorScheme.onSurface,

        /// Цвет текста и иконок поверх альтернативной поверхности (surfaceVariant)
        onSurfaceVariant: colorScheme.onSurfaceVariant,

        /// Цвет текста и иконок поверх инверсированной поверхности
        onInverseSurface: colorScheme.onInverseSurface,

        /// Цвет текста и иконок поверх основного акцента (primary)
        onPrimary: colorScheme.onPrimary,

        /// Цвет текста и иконок поверх второстепенного акцента (secondary)
        onSecondary: colorScheme.onSecondary,

        /// Цвет текста и иконок поверх дополнительного акцента (tertiary)
        onTertiary: colorScheme.onTertiary,

        /// Цвет текста и иконок поверх цвета ошибок (error)
        onError: colorScheme.onError,
      ),
      state: StateColors(
        /// Цвет, обозначающий ошибки
        error: colorScheme.error,

        /// Цвет контейнера для сообщений об ошибках
        errorContainer: colorScheme.errorContainer,

        /// Инверсированный основной цвет, используемый для выделения на тёмных фонах
        inversePrimary: colorScheme.inversePrimary,
      ),
      util: UtilityColors(
        /// Цвет границ или разделителей
        outline: colorScheme.outline,

        /// Альтернативный цвет для границ
        outlineVariant: colorScheme.outlineVariant,

        /// Цвет теней, используемых для создания глубины
        shadow: colorScheme.shadow,

        /// Цвет затемнения для модальных окон или блокирующих слоёв
        scrim: colorScheme.scrim,

        /// Цвет оттенков поверхности при взаимодействии (например, при наведении или нажатии)
        surfaceTint: colorScheme.surfaceTint,
      ),
    );
  }
}
