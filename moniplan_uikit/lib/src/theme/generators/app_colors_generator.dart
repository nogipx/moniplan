import 'package:flutter/material.dart';

import '../_index.dart';

/// Функция, генерирующая [AppColors] из [PaletteColors]
AppColors generateAppColorsFromPalette(PaletteColors palette) {
  return AppColors(
    palette: palette,
    background: BackgroundColors(
      primary: palette.background,
      secondary: palette.surface,
      tertiary: palette.onSecondary, // Добавлен обязательный параметр tertiary
      appBar: palette.primary,
      drawer: palette.background,
      bottomNav: palette.surface,
    ),
    text: TextColors(
      primary: palette.onBackground,
      secondary: palette.onSurface,
      accent: palette.primary,
      disabled: palette.onSurface,
      hint: palette.onSurface,
      inverse: palette.onPrimary,
      error: palette.error,
    ),
    button: ButtonColors(
      primary: palette.primary,
      secondary: palette.secondary,
      tertiary: palette.surface, // Добавлен обязательный параметр tertiary
      pressed: palette.primary,
      hovered: palette.primary, // Уменьшена прозрачность для более мягкого взаимодействия
      disabled: palette.onSurface, // Уменьшена прозрачность для более гармоничного вида
      overlay: palette.primary, // Уменьшена прозрачность для более тонкого эффекта
    ),
    element: ElementColors(
      card: palette.surface,
      modal: palette.surface, // Легкое уменьшение прозрачности для модальных окон
      border: palette.onSurface, // Увеличена прозрачность для лучшей видимости границ
      shadow: Colors.black, // Уменьшена интенсивность тени для более мягкого вида
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
