// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

extension ColorSchemeLerp on ColorScheme {
  ColorScheme lerp(ColorScheme? b, double t) {
    return ColorScheme(
      primary: Color.lerp(primary, b?.primary, t) ?? primary,
      onPrimary: Color.lerp(onPrimary, b?.onPrimary, t) ?? onPrimary,
      primaryContainer: Color.lerp(primaryContainer, b?.primaryContainer, t) ?? primaryContainer,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, b?.onPrimaryContainer, t) ?? onPrimaryContainer,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? secondary,
      onSecondary: Color.lerp(onSecondary, b?.onSecondary, t) ?? onSecondary,
      secondaryContainer:
          Color.lerp(secondaryContainer, b?.secondaryContainer, t) ?? secondaryContainer,
      onSecondaryContainer:
          Color.lerp(onSecondaryContainer, b?.onSecondaryContainer, t) ?? onSecondaryContainer,
      tertiary: Color.lerp(tertiary, b?.tertiary, t) ?? tertiary,
      onTertiary: Color.lerp(onTertiary, b?.onTertiary, t) ?? onTertiary,
      tertiaryContainer:
          Color.lerp(tertiaryContainer, b?.tertiaryContainer, t) ?? tertiaryContainer,
      onTertiaryContainer:
          Color.lerp(onTertiaryContainer, b?.onTertiaryContainer, t) ?? onTertiaryContainer,
      error: Color.lerp(error, b?.error, t) ?? error,
      onError: Color.lerp(onError, b?.onError, t) ?? onError,
      errorContainer: Color.lerp(errorContainer, b?.errorContainer, t) ?? errorContainer,
      onErrorContainer: Color.lerp(onErrorContainer, b?.onErrorContainer, t) ?? onErrorContainer,
      surface: Color.lerp(surface, b?.surface, t) ?? surface,
      onSurface: Color.lerp(onSurface, b?.onSurface, t) ?? onSurface,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, b?.onSurfaceVariant, t) ?? onSurfaceVariant,
      inverseSurface: Color.lerp(inverseSurface, b?.inverseSurface, t) ?? inverseSurface,
      onInverseSurface: Color.lerp(onInverseSurface, b?.onInverseSurface, t) ?? onInverseSurface,
      outline: Color.lerp(outline, b?.outline, t) ?? outline,
      shadow: Color.lerp(shadow, b?.shadow, t) ?? shadow,
      brightness: t < 0.5 ? brightness : b?.brightness ?? brightness,
    );
  }
}
