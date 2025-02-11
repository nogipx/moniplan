// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_app/_run/db/_index.dart';
import 'package:moniplan_app/features/_common/periodic_theme_changer/_index.dart';
import 'package:moniplan_app/features/planners_list/_index.dart';
import 'package:moniplan_app/features/receive_import_sharing/bloc/_index.dart';
import 'package:moniplan_app/features/receive_import_sharing/receive_import_wrapper.dart';
import 'package:moniplan_app/i18n/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
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
  late Brightness _brightness;

  Brightness get _platformBrigtness =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();

    // register(
    //   Service(
    //     name: 'Moniplan',
    //     type: '_moniplan._tcp',
    //     port: 12344,
    //   ),
    // );

    Posthog().capture(eventName: 'testEvent', properties: {'msg': 'hi'});
    _brightness = _platformBrigtness;

    Posthog().reloadFeatureFlags().then((a) {
      Posthog().isFeatureEnabled('Test').then((e) {
        print('FEATURE TEST: $e');
      });
    });
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReceiveImportSharingBloc(
            monisyncRepo: AppDi.instance.getMonisyncRepo(),
          ),
        )
      ],
      child: AnimatedBuilder(
        animation: AppDbImpl(),
        builder: (context, _) {
          return OKToast(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme.themeData,
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              locale: const Locale('ru'), // Укажите текущую локаль
              navigatorObservers: [
                // The PosthogObserver records screen views automatically
                PosthogObserver(),
              ],
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
              home: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AppColorsDisplayScreen(),
                        ),
                      );
                    },
                    child: home,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      key: ValueKey(_brightness),
      builder: (light, dark) {
        return PeriodicThemeChanger(
          type: PeriodicThemeChangerType.rainbow,
          isEnabled: false,
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
              ReceiveImportWrapper(
                child: PlannersListScreen(),
              ),
            );
          },
        );
      },
    );
  }
}
