import 'package:moniplan/theme/_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class ThemeChangerStorageSharedPreferences
    implements IThemeChangerStorage {
  final SharedPreferences sharedPreferences;

  ThemeChangerStorageSharedPreferences({
    required this.sharedPreferences,
  });

  @override
  Future<ThemeBrightness> getSavedBrightness() async {
    final name = sharedPreferences.getString('theme_changer@brightness');
    return name != null && name.isNotEmpty
        ? ThemeBrightness.fromName(name)
        : ThemeBrightness.system;
  }

  @override
  Future<void> persistBrightness(ThemeBrightness brightness) async {
    await sharedPreferences.setString(
      'theme_changer@brightness',
      brightness.name,
    );
  }
}
