import 'package:moniplan/module/operation_list/export.dart';
import 'package:navigation_manager/navigation_manager.dart';

abstract class Routes {
  static final main = AppRoute(
    '/',
    (_) => const OperationListScreen(),
  );

  static final deeplink = [
    main,
  ];
}
