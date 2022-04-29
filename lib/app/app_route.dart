import 'package:flutter/cupertino.dart';
import 'package:moniplan/module/main/screens/main_screen.dart';
import 'package:navigation_manager/navigation_manager.dart';

abstract class Routes {
  static final main = AppRoute(
    '/',
    (_) => const MainScreen(),
  );

  static final deeplink = [
    main,
  ];
}
