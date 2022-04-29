import 'package:flutter/material.dart';
import 'package:moniplan/app/app_route.dart';
import 'package:moniplan/app/app_theme.dart';
import 'package:navigation_manager/navigation_manager.dart';

class MoniplanApp extends StatelessWidget {
  MoniplanApp({
    Key? key,
  }) : super(key: key);

  late final manager = RouteManager(
    initialRoute: Routes.main,
  );

  late final informationParser = AppRouteInformationParser(
    routes: Routes.deeplink,
    unknownRoute: Routes.main,
  );

  late final delegate = AppRouteDelegate(routeManager: manager);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      routeInformationParser: informationParser,
      routerDelegate: delegate,
      builder: (context, child) {
        return child!;
      },
    );
  }
}
