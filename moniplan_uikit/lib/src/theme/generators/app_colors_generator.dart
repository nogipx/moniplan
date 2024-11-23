import 'package:flutter/material.dart';

import '../_index.dart';

/// Функция, генерирующая [AppColors] из [PaletteColors]
AppColors generateAppColorsFromPalette(PaletteColors palette) {
  return AppColors(
    palette: palette,
    background: BackgroundColors(
      primary: palette.background,
      secondary: palette.surface.withOpacity(0.9),
      tertiary: palette.surface, // Добавлен обязательный параметр tertiary
      appBar: palette.primary.withOpacity(0.8),
      drawer: palette.background.withOpacity(0.8),
      bottomNav: palette.surface,
    ),
    text: TextColors(
      primary: palette.onBackground,
      secondary: palette.onSurface.withOpacity(0.7),
      accent: palette.primary,
      disabled: palette.onSurface.withOpacity(0.38),
      hint: palette.onSurface.withOpacity(0.5),
      inverse: palette.onPrimary,
      error: palette.error,
    ),
    button: ButtonColors(
      primary: palette.primary,
      secondary: palette.secondary,
      tertiary: palette.surface, // Добавлен обязательный параметр tertiary
      pressed: palette.primary.withOpacity(0.7),
      hovered: palette.primary
          .withOpacity(0.85), // Уменьшена прозрачность для более мягкого взаимодействия
      disabled:
          palette.onSurface.withOpacity(0.3), // Уменьшена прозрачность для более гармоничного вида
      overlay:
          palette.primary.withOpacity(0.08), // Уменьшена прозрачность для более тонкого эффекта
    ),
    element: ElementColors(
      card: palette.surface,
      modal: palette.surface.withOpacity(0.85), // Легкое уменьшение прозрачности для модальных окон
      border:
          palette.onSurface.withOpacity(0.15), // Увеличена прозрачность для лучшей видимости границ
      shadow: Colors.black.withOpacity(0.15), // Уменьшена интенсивность тени для более мягкого вида
      divider:
          palette.onSurface.withOpacity(0.1), // Уменьшена прозрачность для более легкого разделения
      highlight: palette.secondary.withOpacity(0.25), // Более мягкий оттенок для выделения
      background: palette.background, // Добавлен обязательный параметр background
    ),
    state: StateColors(
      active: palette.primary,
      inactive:
          palette.onSurface.withOpacity(0.4), // Уменьшена прозрачность для более четкого различия
      error: palette.error,
      success: palette.secondary.withOpacity(0.7), // Заменен на более гармоничный оттенок
      warning: palette.primary.withOpacity(0.6), // Использован цвет из палитры для согласованности
    ),
  );
}
