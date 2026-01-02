import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/features/planners_list/_index.dart';
import 'package:moniplan_app/modules/periodic_theme_changer/periodic_theme_changer.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/date_extension.dart';

class MoniplanApp extends StatefulWidget {
  const MoniplanApp({required this.sharedPreferences, super.key});

  final SharedPreferences sharedPreferences;

  @override
  State<MoniplanApp> createState() => _MoniplanAppState();
}

class _MoniplanAppState extends State<MoniplanApp> {
  late Brightness _brightness;

  Brightness get _platformBrigtness =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();

    _brightness = _platformBrigtness;

    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = _onBrightnessChanged;
  }

  void _onBrightnessChanged() {
    final newBrightness = _platformBrigtness;
    if (newBrightness != _brightness) {
      setState(() {
        _brightness = newBrightness;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = null;
    super.dispose();
  }

  Widget app(AppTheme theme, Widget home) {
    return AnimatedBuilder(
      animation: AppDi.instance.getDb() as AppDbImpl,
      builder: (context, _) {
        return OKToast(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme.themeData,
            // localizationsDelegates: [S.delegate],
            // supportedLocales: S.delegate.supportedLocales,
            // locale: const Locale('ru'), // Укажите текущую локаль
            builder: (context, child) => ResponsiveBreakpoints.builder(
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
              child: Stack(
                children: [
                  Positioned.fill(child: child!),
                ],
              ),
            ),
            home: Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => AppColorsDisplayScreen()));
                  },
                  child: home,
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      key: ValueKey(_brightness),
      builder: (light, dark) {
        return PeriodicThemeChanger(
          type: PeriodicThemeChangerType.rainbow,
          changePeriod: const Duration(seconds: 7),
          initialTheme: moniplanThemeGeneratorDynamicSync(
            brightness: _brightness,
            dark: dark,
            light: light,
          ),
          rainbowSeedGenerator: () => DateTime.now().minuteBound.millisecondsSinceEpoch,
          builder: (context, theme) {
            return app(
              theme ??
                  moniplanThemeGeneratorDynamicSync(
                    brightness: _brightness,
                    dark: dark,
                    light: light,
                  ),
              const PlannersListScreen(),
            );
          },
        );
      },
    );
  }
}
