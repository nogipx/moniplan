import 'package:flutter/material.dart';

// Define your custom theme extensions here
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primaryColor;
  final String fontFamily;

  AppThemeExtension({
    required this.primaryColor,
    required this.fontFamily,
  });

  @override
  AppThemeExtension copyWith({Color? primaryColor, String? fontFamily}) {
    return AppThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t) ?? primaryColor,
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
    );
  }
}

// Configured Dark Theme
ThemeData getDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF0C82D8),
    scaffoldBackgroundColor: Color(0xFF121212),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontFamily: 'TTNeoris', color: Colors.white),
      bodyMedium: TextStyle(fontFamily: 'TTNeoris', color: Colors.white70),
      titleSmall: TextStyle(fontFamily: 'TTNeoris', color: Colors.white),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0C82D8),
      titleTextStyle: TextStyle(fontFamily: 'TTNeoris', fontSize: 20, color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF0C82D8),
      textTheme: ButtonTextTheme.primary,
    ),
    extensions: [
      AppThemeExtension(
        primaryColor: Color(0xFF0C82D8),
        fontFamily: 'TTNeoris',
      ),
    ],
  );
}

// Configured Light Theme
ThemeData getLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF0C82D8),
    scaffoldBackgroundColor: Color(0xFFF1F1F1),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontFamily: 'TTNeoris', color: Colors.black),
      bodyMedium: TextStyle(fontFamily: 'TTNeoris', color: Colors.black87),
      titleSmall: TextStyle(fontFamily: 'TTNeoris', color: Colors.black),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0C82D8),
      titleTextStyle: TextStyle(fontFamily: 'TTNeoris', fontSize: 20, color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF0C82D8),
      textTheme: ButtonTextTheme.primary,
    ),
    extensions: [
      AppThemeExtension(
        primaryColor: Color(0xFF0C82D8),
        fontFamily: 'TTNeoris',
      ),
    ],
  );
}
