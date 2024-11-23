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

            // Задайте исходный цвет
            final sourceColorArgb = 0xFF6200EE;

            // // Создайте палитры тонов
            // final TonalPalette primaryPalette = TonalPalette.of(sourceColorArgb);
            // final TonalPalette secondaryPalette = TonalPalette.of(sourceColorArgb);
            // final TonalPalette tertiaryPalette = TonalPalette.of(sourceColorArgb);
            // final TonalPalette neutralPalette = TonalPalette.of(sourceColorArgb);
            // final TonalPalette neutralVariantPalette = TonalPalette.of(sourceColorArgb);
            //
            // // Создайте DynamicScheme
            // final DynamicScheme dynamicScheme = DynamicScheme(
            //   sourceColorArgb: sourceColorArgb,
            //   variant: Variant.tone,
            //   contrastLevel: 0.0,
            //   isDark: false,
            //   primaryPalette: primaryPalette,
            //   secondaryPalette: secondaryPalette,
            //   tertiaryPalette: tertiaryPalette,
            //   neutralPalette: neutralPalette,
            //   neutralVariantPalette: neutralVariantPalette,
            // );

            // Создайте ColorScheme на основе DynamicScheme
            final ColorScheme colorScheme = generateColorSchemeFromSeed(
              seedColor: AppColorsRaw.oliveBlack,
              isDarkTheme: true,
            );

            var resultTheme = theme(
              customColors: AppColors.fromColorScheme(colorScheme),
              themeStyle: ThemeStyle.dark,
              baseTextStyle: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontFamily: 'TTNeoris',
              ),
              // customColors: result,
            );

            resultTheme = resultTheme.copyWith(
              colorScheme: resultTheme.colorScheme.harmonized(),
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
              // home: AppColorsDisplayScreen(appColors: result),
            );
          },
        ),
      ),
    );
  }
}

// Генерация ColorScheme из сида цвета с использованием DynamicScheme

ColorScheme generateColorSchemeFromSeed({
  required Color seedColor,
  required bool isDarkTheme,
}) {
  // Convert Flutter Color to ARGB integer
  final int seedColorArgb = seedColor.value;

  // Create a CorePalette from the seed color
  final CorePalette corePalette = CorePalette.of(seedColorArgb);
  final brightness = isDarkTheme ? Brightness.dark : Brightness.light;

  // Select the appropriate tonal palette based on brightness
  final TonalPalette primaryPalette = corePalette.primary;
  final TonalPalette secondaryPalette = corePalette.secondary;
  final TonalPalette tertiaryPalette = corePalette.tertiary;
  final TonalPalette neutralPalette = corePalette.neutral;
  final TonalPalette neutralVariantPalette = corePalette.neutralVariant;
  final TonalPalette errorPalette = corePalette.error;

  // Define tones based on brightness
  final int primaryTone = brightness == Brightness.light ? 40 : 80;
  final int onPrimaryTone = brightness == Brightness.light ? 100 : 20;
  final int primaryContainerTone = brightness == Brightness.light ? 90 : 30;
  final int onPrimaryContainerTone = brightness == Brightness.light ? 10 : 90;

  // Repeat for other color roles as needed...

  return ColorScheme(
    brightness: brightness,
    primary: Color(primaryPalette.get(primaryTone)),
    onPrimary: Color(primaryPalette.get(onPrimaryTone)),
    primaryContainer: Color(primaryPalette.get(primaryContainerTone)),
    onPrimaryContainer: Color(primaryPalette.get(onPrimaryContainerTone)),
    secondary: Color(secondaryPalette.get(primaryTone)),
    onSecondary: Color(secondaryPalette.get(onPrimaryTone)),
    secondaryContainer: Color(secondaryPalette.get(primaryContainerTone)),
    onSecondaryContainer: Color(secondaryPalette.get(onPrimaryContainerTone)),
    tertiary: Color(tertiaryPalette.get(primaryTone)),
    onTertiary: Color(tertiaryPalette.get(onPrimaryTone)),
    tertiaryContainer: Color(tertiaryPalette.get(primaryContainerTone)),
    onTertiaryContainer: Color(tertiaryPalette.get(onPrimaryContainerTone)),
    error: Color(errorPalette.get(primaryTone)),
    onError: Color(errorPalette.get(onPrimaryTone)),
    errorContainer: Color(errorPalette.get(primaryContainerTone)),
    onErrorContainer: Color(errorPalette.get(onPrimaryContainerTone)),
    background: Color(neutralPalette.get(primaryContainerTone)),
    onBackground: Color(neutralPalette.get(onPrimaryContainerTone)),
    surface: Color(neutralPalette.get(primaryContainerTone)),
    onSurface: Color(neutralPalette.get(onPrimaryContainerTone)),
    surfaceVariant: Color(neutralVariantPalette.get(primaryContainerTone)),
    onSurfaceVariant: Color(neutralVariantPalette.get(onPrimaryContainerTone)),
    outline: Color(neutralVariantPalette.get(primaryTone)),
    shadow: Colors.black,
    inverseSurface: Color(neutralPalette.get(onPrimaryContainerTone)),
    onInverseSurface: Color(neutralPalette.get(primaryTone)),
    inversePrimary: Color(primaryPalette.get(onPrimaryTone)),
    surfaceTint: Color(primaryPalette.get(primaryTone)),
  );
}
