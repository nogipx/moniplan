import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Расширение для [BuildContext]
extension BuildContextThemeExtension on BuildContext {
  /// Получение [ThemeData] из [BuildContext].
  ThemeData get theme => Theme.of(this);

  AppThemeData get themeExtension => theme.ext;

  AppColors get color => themeExtension.colors;

  AppTextTheme get text => themeExtension.text;

  AppShadowTheme get shadow => themeExtension.shadow;

  AppButtonStyle get button => themeExtension.button;
}
