import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:moniplan/app/export.dart';
import 'package:navigation_manager/navigation_manager.dart';

class AppWM extends WidgetModel<MoniplanResponsiveApp, AppModel> {
  late final manager = RouteManager(
    initialRoute: Routes.main,
  );

  late final informationParser = AppRouteInformationParser(
    routes: Routes.deeplink,
    unknownRoute: Routes.main,
  );

  late final delegate = AppRouteDelegate(routeManager: manager);

  AppWM(AppModel model) : super(model);

  @override
  void initWidgetModel() {
    super.initWidgetModel();
  }
}

AppWM appFactory(BuildContext _) => AppWM(AppModel());
