import 'package:flutter/material.dart';
import 'package:moniplan/features/feature_planners_management/screens/planners_list_screen.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoniplanApp extends StatefulWidget {
  const MoniplanApp({
    super.key,
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  @override
  State<MoniplanApp> createState() => _MoniplanAppState();
}

class _MoniplanAppState extends State<MoniplanApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeChanger(
      storage: ThemeChangerStorageSharedPreferences(
        sharedPreferences: widget.sharedPreferences,
      ),
      onChangeTheme: (brightness) {
        MoniplanColors.brightness = brightness;
      },
      builder: (context) {
        return const MaterialApp(
          home: PlannersListScreen(),
        );
      },
    );
  }
}
