import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/_run/db/_index.dart';
import 'package:moniplan/features/monisync/repo/monisync_repo_impl.dart';
import 'package:moniplan/features/monisync/screens/monisync_screen.dart';
import 'package:moniplan/features/planners_list//_index.dart';
import 'package:moniplan/features/receive_import_sharing/bloc/_index.dart';
import 'package:moniplan/features/receive_import_sharing/receive_import_wrapper.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen.dart';

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
  final variants = [
    FlexSchemeVariant.material3Legacy,
    FlexSchemeVariant.material,
    FlexSchemeVariant.expressive,
    FlexSchemeVariant.rainbow,
    FlexSchemeVariant.content,
    FlexSchemeVariant.candyPop,
    FlexSchemeVariant.chroma,
    FlexSchemeVariant.fidelity,
    FlexSchemeVariant.fruitSalad,
    FlexSchemeVariant.jolly,
    FlexSchemeVariant.monochrome,
    FlexSchemeVariant.neutral,
    FlexSchemeVariant.oneHue,
    FlexSchemeVariant.soft,
    FlexSchemeVariant.tonalSpot,
    FlexSchemeVariant.highContrast,
    FlexSchemeVariant.ultraContrast,
    FlexSchemeVariant.vibrant,
    FlexSchemeVariant.vivid,
    FlexSchemeVariant.vividBackground,
    FlexSchemeVariant.vividSurfaces,
  ];

  // late final ValueNotifier<ThemeData> _theme;
  // late final Timer _ticker;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    // _theme = ValueNotifier(_getTheme(variants[counter]));
    // _ticker = Timer.periodic(
    //   const Duration(seconds: 2),
    //   (timer) {
    //     setState(() {
    //       counter++;
    //       final index = counter % variants.length;
    //       print(index);
    //       _theme.value = _getTheme(variants[index]);
    //     });
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    final home = ReceiveImportWrapper(
      child: PlannersListScreen(),
      // child: TestRecolorScreen(),
      // child: AppColorsDisplayScreen(
      //   appColors: theme.appThemeData.colors,
      //   colorScheme: theme.themeData.colorScheme,
      // ),
    );

    return DynamicColorBuilder(
      builder: (light, dark) {
        final brightness = MediaQuery.of(context).platformBrightness;
        final scheme = brightness == Brightness.dark ? dark : light;
        final theme = moniplanTheme(
          seedScheme: scheme,
          brightness: brightness,
          variant: FlexSchemeVariant.vivid,
          monochrome: false,
        );

        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<IMonisyncRepo>(
              create: (_) => MonisyncRepoImpl(encryptKey: mockEncryptionKey),
            )
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => ReceiveImportSharingBloc(monisyncRepo: context.read()),
              )
            ],
            child: AnimatedBuilder(
              animation: AppDbImpl(),
              builder: (context, _) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: theme.themeData,
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
                              builder: (context) => AppColorsDisplayScreen(
                                appColors: theme.appThemeData.colors,
                                colorScheme: scheme ?? ColorScheme.dark(),
                              ),
                            ),
                          );
                        },
                        child: home,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
