import 'dart:math';

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
  @override
  Widget build(BuildContext context) {
    final home = ReceiveImportWrapper(
      child: PlannersListScreen(),
      // child: TestRecolorScreen(),
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
            final random = Random().nextDouble();
            final rainbow = generateRainbowColor(random);
            final targetColor = AppColorsRaw.brightBlue;

            // final colors = AppColors.fromColorScheme(
            //   ColorScheme.fromSwatch(
            //     primarySwatch: Colors.blue,
            //     brightness: Brightness.dark,
            //   ),
            // );

            final colors = AppColors.fromSeedColor(
              seedColor: rainbow,
              isDarkTheme: false,
            );

            var resultTheme = theme(
              baseTextStyle: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontFamily: 'TTNeoris',
              ),
              customColors: colors,
            );

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: resultTheme,
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
              home: home,
              // home: AppColorsDisplayScreen(appColors: colors, colorScheme: colors.scheme),
            );
          },
        ),
      ),
    );
  }
}
