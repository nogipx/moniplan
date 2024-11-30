import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/_run/db/_index.dart';
import 'package:moniplan/features/_common/periodic_theme_changer/_index.dart';
import 'package:moniplan/features/_common/screens/app_colors_display_screen.dart';
import 'package:moniplan/features/monisync/repo/monisync_repo_impl.dart';
import 'package:moniplan/features/monisync/screens/monisync_screen.dart';
import 'package:moniplan/features/planners_list//_index.dart';
import 'package:moniplan/features/receive_import_sharing/bloc/_index.dart';
import 'package:moniplan/features/receive_import_sharing/receive_import_wrapper.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_index.dart';

class MoniplanApp extends StatefulWidget {
  const MoniplanApp({
    super.key,
    required this.sharedPreferences,
    this.initialTheme,
  });

  final SharedPreferences sharedPreferences;
  final AppTheme? initialTheme;

  @override
  State<MoniplanApp> createState() => _MoniplanAppState();
}

class _MoniplanAppState extends State<MoniplanApp> {
  final _appKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final home = ReceiveImportWrapper(
      child: PlannersListScreen(),
    );

    return PeriodicThemeChanger(
      isEnabled: true,
      type: PeriodicThemeChangerType.rainbow,
      initialTheme: widget.initialTheme,
      themeProvider: moniplanThemeGeneratorDynamic,
      rainbowSeed: moniplanThemeRandomRainbow,
      variants: FlexSchemeVariant.values,
      changePeriod: const Duration(milliseconds: 300),
      builder: (context, theme) {
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
                  key: _appKey,
                  debugShowCheckedModeBanner: false,
                  theme: theme?.themeData,
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
                );
              },
            ),
          ),
        );
      },
    );
  }
}
