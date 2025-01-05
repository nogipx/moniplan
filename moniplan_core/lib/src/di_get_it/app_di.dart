import 'package:moniplan_core/moniplan_core.dart';

abstract class AppDi implements IAppDi {
  static late final AppDi instance;

  @override
  AppDb getDb();
}
