import 'package:flutter/material.dart';
import 'package:moniplan/app_log_impl.dart';
import 'package:moniplan/features/planners_list//_index.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

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
    AppLog.factory = (name) => MoniplanLog(logger: Logger(name));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeChanger(
      initialBrightness: ThemeBrightness.dark,
      storage: ThemeChangerStorageSharedPreferences(
        sharedPreferences: widget.sharedPreferences,
      ),
      onChangeTheme: (brightness) {
        AppColorTokens.brightness = brightness;
      },
      builder: (context, brightness) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'TTNeoris',
            primaryColor: AppColorTokens.brandColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColorTokens.brandColor,
              brightness: Brightness.dark,
            ),
          ),
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(
                start: 0,
                end: 450,
                name: MOBILE,
              ),
              const Breakpoint(
                start: 451,
                end: 800,
                name: TABLET,
              ),
              const Breakpoint(
                start: 801,
                end: 1920,
                name: DESKTOP,
              ),
              const Breakpoint(
                start: 1921,
                end: double.infinity,
                name: '4K',
              ),
            ],
          ),
          home: PlannersListScreen(),
        );
      },
    );
  }
}
