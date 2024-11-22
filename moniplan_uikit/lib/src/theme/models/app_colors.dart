import 'package:moniplan_uikit/src/theme/_index.dart';

/// Класс набора цветов для ui kit
class AppColors {
  final BackgroundColors background;
  final ButtonColors button;
  final ElementColors element;
  final PaletteColors palette;
  final StateColors state;
  final TextColors text;

  /// Создаёт приватный класс набора цветов для ui kit
  const AppColors({
    required this.background,
    required this.button,
    required this.element,
    required this.palette,
    required this.state,
    required this.text,
  });

  /// Набор цветов для [ThemeStyle.dark]
  AppColors.dark()
      : background = BackgroundColors.dark(),
        button = ButtonColors.dark(),
        element = ElementColors.dark(),
        palette = PaletteColors.dark(),
        state = StateColors.dark(),
        text = TextColors.dark();

  /// Набор цветов для [ThemeStyle.light]
  AppColors.light()
      : background = BackgroundColors.light(),
        button = ButtonColors.light(),
        element = ElementColors.light(),
        palette = PaletteColors.light(),
        state = StateColors.light(),
        text = TextColors.light();

  /// Интерполяция для анимированных переходов между [AppColors]
  AppColors lerp(AppColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppColors(
      background: background.lerp(b?.background, t),
      button: button.lerp(b?.button, t),
      element: element.lerp(b?.element, t),
      palette: palette.lerp(b?.palette, t),
      state: state.lerp(b?.state, t),
      text: text.lerp(b?.text, t),
    );
  }

  /// Метод копирования [AppColors]
  AppColors copyWith({
    BackgroundColors? background,
    ButtonColors? button,
    ElementColors? element,
    PaletteColors? palette,
    StateColors? state,
    TextColors? text,
  }) {
    return AppColors(
      background: background ?? this.background,
      button: button ?? this.button,
      element: element ?? this.element,
      palette: palette ?? this.palette,
      state: state ?? this.state,
      text: text ?? this.text,
    );
  }

  /// Получение [AppColors] по [themeStyle]
  static AppColors get(ThemeStyle themeStyle) => switch (themeStyle) {
        ThemeStyle.light => AppColors.light(),
        _ => AppColors.dark(),
      };
}
