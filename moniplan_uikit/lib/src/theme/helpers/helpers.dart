// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// Интерполяция для [int]
int? lerpInt(int? a, int? b, double t) {
  if (a == null) {
    return b;
  } else if (b == null) {
    return a;
  }

  return (a + (b - a) * t).toInt();
}

/// Интерполяция для [BorderSide]
BorderSide? lerpBorderSide(BorderSide? a, BorderSide? b, double t) {
  if (a == null && b == null) {
    return null;
  }

  if (a == null) {
    return BorderSide.lerp(
      BorderSide(width: 0, color: b!.color.withAlpha(0)),
      b,
      t,
    );
  }
  if (b == null) {
    return BorderSide.lerp(
      a,
      BorderSide(width: 0, color: a.color.withAlpha(0)),
      t,
    );
  }
  return BorderSide.lerp(a, b, t);
}

/// Метод необходим, т.к. BorderSide.lerp(...) не поддерживает null-аргументы
WidgetStateProperty<BorderSide?>? lerpSides(
  WidgetStateProperty<BorderSide?>? a,
  WidgetStateProperty<BorderSide?>? b,
  double t,
) {
  if (a == null && b == null) {
    return null;
  }

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
  if ((a?.isEmpty ?? true) && (a?.isNotEmpty ?? false)) {
    return a;
  } else if ((b?.isEmpty ?? true) && (a?.isNotEmpty ?? false)) {
    return b;
  }

  final lerpList = <BoxShadow>[];
  if (a!.length > b!.length) {
    for (var i = 0; i < a.length; i++) {
      final aBoxShadow = a[i];
      if (b.length < i) {
        final box = BoxShadow.lerp(aBoxShadow, b[i], t);
        if (box != null) {
          lerpList.add(box);
        }
      } else {
        lerpList.add(aBoxShadow);
      }
    }
  } else if (a.length < b.length) {
    for (var i = 0; i < b.length; i++) {
      final aBoxShadow = b[i];
      if (a.length < i) {
        final box = BoxShadow.lerp(aBoxShadow, a[i], t);
        if (box != null) {
          lerpList.add(box);
        }
      } else {
        lerpList.add(aBoxShadow);
      }
    }
  } else {
    lerpList.addAll(a);
  }

  return lerpList;
}

MaterialColor getMaterialColor(Color color) {
  final red = color.red;
  final green = color.green;
  final blue = color.blue;
  final alpha = color.alpha;

  final shades = <int, Color>{
    50: Color.fromARGB(alpha, red, green, blue),
    100: Color.fromARGB(alpha, red, green, blue),
    200: Color.fromARGB(alpha, red, green, blue),
    300: Color.fromARGB(alpha, red, green, blue),
    400: Color.fromARGB(alpha, red, green, blue),
    500: Color.fromARGB(alpha, red, green, blue), // default
    600: Color.fromARGB(alpha, red, green, blue),
    700: Color.fromARGB(alpha, red, green, blue),
    800: Color.fromARGB(alpha, red, green, blue),
    900: Color.fromARGB(alpha, red, green, blue),
  };

  return MaterialColor(color.value, shades);
}

/// Получение более тёмного цвета в процентном соотношение [percent]
Color darken(Color c, [int percent = 10]) {
  var effectivePercent = percent;
  if (1 > percent) {
    effectivePercent = 1;
  } else if (percent > 100) {
    effectivePercent = 100;
  }

  final f = 1 - effectivePercent / 100;
  return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(), (c.blue * f).round());
}

/// Получение более светлого цвета в процентном соотношение [percent]
Color lighten(Color c, [int percent = 10]) {
  var effectivePercent = percent;
  if (1 > percent) {
    effectivePercent = 1;
  } else if (percent > 100) {
    effectivePercent = 100;
  }

  final p = effectivePercent / 100;
  return Color.fromARGB(
    c.alpha,
    c.red + ((255 - c.red) * p).round(),
    c.green + ((255 - c.green) * p).round(),
    c.blue + ((255 - c.blue) * p).round(),
  );
}
