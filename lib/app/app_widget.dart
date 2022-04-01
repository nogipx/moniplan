import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:moniplan/app/export.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MoniplanResponsiveApp extends ElementaryWidget<AppWM> {
  const MoniplanResponsiveApp({
    Key? key,
    WidgetModelFactory<AppWM> factory = appFactory,
  }) : super(factory, key: key);

  @override
  Widget build(AppWM wm) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      routeInformationParser: wm.informationParser,
      routerDelegate: wm.delegate,
      builder: (context, child) {
        return ResponsiveWrapper.builder(
          child,
          defaultScale: true,
          breakpoints: [
            const ResponsiveBreakpoint.resize(360, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(800, name: TABLET),
            const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
          ],
          background: Container(
            color: const Color(0xFFF5F5F5),
          ),
        );
      },
    );
  }
}
