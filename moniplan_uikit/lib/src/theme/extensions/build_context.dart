import 'package:flutter/material.dart';

/// Расширение для [BuildContext]
extension BuildContextThemeExtension on BuildContext {
  /// Получение [ThemeData] из [BuildContext].
  ThemeData get theme => Theme.of(this);
}
