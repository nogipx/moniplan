// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

extension BuildContextThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppThemeData get extension => theme.appExtension;

  ColorScheme get color => extension.colors.scheme;

  AppTextTheme get text => extension.text;

  AppShadowTheme get shadow => extension.shadow;

  AppButtonStyle get button => extension.button;

  T? ext<T>() => theme.ext<T>();
}
