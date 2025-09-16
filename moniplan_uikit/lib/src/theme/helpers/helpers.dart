import 'package:flutter/material.dart';

extension ColorX on Color {
  String get hex {
    final rHex = (r * 255.0).round().toRadixString(16).padLeft(2, '0');
    final gHex = (g * 255.0).round().toRadixString(16).padLeft(2, '0');
    final bHex = (b * 255.0).round().toRadixString(16).padLeft(2, '0');
    return '#$rHex$gHex$bHex';
  }
}

/// Интерполяция для [int]
int? lerpInt(int? a, int? b, double t) {
  if (a == null) return b;
  if (b == null) return a;
  return (a + (b - a) * t).toInt();
}

/// Интерполяция для [BorderSide]
BorderSide? lerpBorderSide(BorderSide? a, BorderSide? b, double t) {
  if (a == null && b == null) return null;
  if (a == null) return BorderSide.lerp(BorderSide(width: 0, color: b!.color.withAlpha(0)), b, t);
  if (b == null) return BorderSide.lerp(a, BorderSide(width: 0, color: a.color.withAlpha(0)), t);
  return BorderSide.lerp(a, b, t);
}

/// Метод необходим, т.к. BorderSide.lerp(...) не поддерживает null-аргументы
WidgetStateProperty<BorderSide?>? lerpSides(
  WidgetStateProperty<BorderSide?>? a,
  WidgetStateProperty<BorderSide?>? b,
  double t,
) {
  if (a == null && b == null) return null;
  return _LerpSides(a, b, t);
}

class _LerpSides implements WidgetStateProperty<BorderSide?> {
  final WidgetStateProperty<BorderSide?>? a;
  final WidgetStateProperty<BorderSide?>? b;
  final double t;

  const _LerpSides(this.a, this.b, this.t);

  @override
  BorderSide? resolve(Set<WidgetState> states) {
    final resolvedA = a?.resolve(states);
    final resolvedB = b?.resolve(states);
    return lerpBorderSide(resolvedA, resolvedB, t);
  }
}

/// Интерполяция для [BoxShadow]
List<BoxShadow>? lerpBoxShadow(List<BoxShadow>? a, List<BoxShadow>? b, double t) {
  if (a == null && b == null) return null;
  if (a == null) return List<BoxShadow>.from(b!);
  if (b == null) return List<BoxShadow>.from(a);

  final minLen = a.length < b.length ? a.length : b.length;
  final result = <BoxShadow>[];
  for (var i = 0; i < minLen; i++) {
    final box = BoxShadow.lerp(a[i], b[i], t);
    if (box != null) result.add(box);
  }
  if (a.length > minLen) result.addAll(a.sublist(minLen));
  if (b.length > minLen) result.addAll(b.sublist(minLen));
  return result;
}

/// Возвращает MaterialColor, построенный на основе переданного цвета
MaterialColor getMaterialColor(Color color) {
  final int argb = color.toARGB32();
  final int a = (argb >> 24) & 0xFF;
  final int r = (argb >> 16) & 0xFF;
  final int g = (argb >> 8) & 0xFF;
  final int b = argb & 0xFF;

  final shades = <int, Color>{
    50: Color.fromARGB(a, r, g, b),
    100: Color.fromARGB(a, r, g, b),
    200: Color.fromARGB(a, r, g, b),
    300: Color.fromARGB(a, r, g, b),
    400: Color.fromARGB(a, r, g, b),
    500: Color.fromARGB(a, r, g, b),
    600: Color.fromARGB(a, r, g, b),
    700: Color.fromARGB(a, r, g, b),
    800: Color.fromARGB(a, r, g, b),
    900: Color.fromARGB(a, r, g, b),
  };

  return MaterialColor(argb, shades);
}

/// Получение более тёмного цвета в процентном соотношение [percent]
Color darken(Color c, [int percent = 10]) {
  final int pct = percent.clamp(1, 100);
  final int v = c.toARGB32();
  final int a = (v >> 24) & 0xFF;
  final int r = (v >> 16) & 0xFF;
  final int g = (v >> 8) & 0xFF;
  final int b = v & 0xFF;

  final double f = 1 - pct / 100;
  return Color.fromARGB(a, (r * f).round(), (g * f).round(), (b * f).round());
}

/// Получение более светлого цвета в процентном соотношение [percent]
Color lighten(Color c, [int percent = 10]) {
  final int pct = percent.clamp(1, 100);
  final int v = c.toARGB32();
  final int a = (v >> 24) & 0xFF;
  final int r = (v >> 16) & 0xFF;
  final int g = (v >> 8) & 0xFF;
  final int b = v & 0xFF;

  final double p = pct / 100;
  return Color.fromARGB(
    a,
    (r + ((255 - r) * p)).round(),
    (g + ((255 - g) * p)).round(),
    (b + ((255 - b) * p)).round(),
  );
}
