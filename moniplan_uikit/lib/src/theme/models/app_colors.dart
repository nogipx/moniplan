// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class AppColors {
  final ColorScheme scheme;

  Brightness get brightness => scheme.brightness;

  AppColors({
    required this.scheme,
  });

  /// Набор цветов для [Brightness.dark]
  AppColors.dark() : scheme = ColorScheme.dark();

  /// Набор цветов для [Brightness.light]
  AppColors.light() : scheme = ColorScheme.light();

  static AppColors get(Brightness _) => switch (_) {
        Brightness.light => AppColors.light(),
        _ => AppColors.dark(),
      };

  /// Интерполяция для анимированных переходов между [AppColors]
  AppColors lerp(AppColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppColors(
      scheme: ColorSchemeLerp(scheme).lerp(b?.scheme, t),
    );
  }

  /// Метод копирования [AppColors]
  AppColors copyWith({
    ColorScheme? scheme,
  }) {
    return AppColors(
      scheme: scheme ?? this.scheme,
    );
  }
}
