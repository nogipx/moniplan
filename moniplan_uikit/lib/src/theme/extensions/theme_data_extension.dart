import 'package:flutter/material.dart';

import '../_index.dart';

typedef ThemeDataGenerator = ThemeData Function(AppThemeData data, bool useMaterial3);

/// Расширение для [ThemeData]
extension ThemeDataExtension on ThemeData {
  /// Получение [AppThemeData] из [BuildContext].
  AppThemeData get ext => extension<AppThemeData>()!;

  static ThemeDataGenerator? generator;

  static ThemeData fromData(AppThemeData data, {bool useMaterial3 = true}) {
    if (generator != null) {
      return generator!(data, useMaterial3);
    }

    final colors = data.colors;
    final text = data.text;

    return ThemeData(
      useMaterial3: useMaterial3,
      extensions: [data],
      brightness: colors.brightness,
      fontFamily: text.baseTextStyle.fontFamily,
      textTheme: text.value,
      primaryTextTheme: text.value,
      colorScheme: colors.scheme,
      appBarTheme: data.appBar.value,
    );
  }
}
