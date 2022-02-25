import 'package:flutter/material.dart';
import 'package:moniplan/screen/operations_screen_mob.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'theme.dart';

class Moniplan extends StatelessWidget {
  const Moniplan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      builder: (context, child) {
        return ResponsiveWrapper.builder(
          child,
          // minWidth: 480,
          // maxWidth: 360,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.resize(360, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.resize(1200, name: DESKTOP),
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
