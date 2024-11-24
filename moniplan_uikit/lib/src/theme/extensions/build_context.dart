import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Расширение для [BuildContext]
extension BuildContextThemeExtension on BuildContext {
  /// Получение [ThemeData] из [BuildContext].
  ThemeData get theme => Theme.of(this);

  AppThemeData get appTheme => theme.app;

  AppColors get color => appTheme.colors;

  AppTextTheme get text => appTheme.text;

  AppBorderRadiuses get radius => appTheme.radius;

  AppSpaces get space => appTheme.space;

  AppShadowTheme get shadow => appTheme.shadow;

  AppButtonStyle get button => appTheme.buttonStyle;
}
