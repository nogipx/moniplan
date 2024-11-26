import 'package:flutter/material.dart';

import '../_index.dart';

typedef ThemeDataGenerator = ThemeData Function(
  AppThemeData data,
  List<ThemeExtension> extensions,
  bool useMaterial3,
);

/// Расширение для [ThemeData]
extension ThemeDataExtension on ThemeData {
  /// Получение [AppThemeData] из [BuildContext].
  AppThemeData get appExtension => extension<AppThemeData>()!;

  T? ext<T>() => extension<T>();

  static ThemeDataGenerator? generator;

  static ThemeData fromData(
    AppThemeData data, {
    List<ThemeExtension> extensions = const [],
    bool useMaterial3 = true,
  }) {
    if (generator != null) {
      return generator!(data, extensions, useMaterial3);
    }

    final colors = data.colors;
    final text = data.text;

    return ThemeData(
      useMaterial3: useMaterial3,
      extensions: [data, ...extensions],
      brightness: colors.brightness,
      fontFamily: text.baseTextStyle.fontFamily,
      textTheme: text.value,
      primaryTextTheme: text.value,
      colorScheme: colors.scheme,
      appBarTheme: data.appBar.value,
    );
  }
}
