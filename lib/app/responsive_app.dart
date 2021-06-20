import 'package:flutter/material.dart';
import 'package:moniplan/screen/export.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MoniplanResponsiveApp extends StatelessWidget {
  const MoniplanResponsiveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ResponsiveWrapper.builder(
          child,
          // minWidth: 480,
          // maxWidth: 360,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.resize(480, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.resize(1000, name: DESKTOP),
            ResponsiveBreakpoint.autoScale(1600),
          ],
          background: Container(
            color: Color(0xFFF5F5F5),
          ),
        );
      },
      home: OperationsScreenMob(),
    );
  }
}
