import 'package:flutter/material.dart';

import '../_index.dart';

/// Расширение для [ThemeData]
extension BuildContextThemeDataExtension on ThemeData {
  /// Получение [AppThemeData] из [BuildContext].
  AppThemeData get app => extension<AppThemeData>()!;
}
