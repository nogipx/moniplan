import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_app/_run/log/app_log_impl.dart';
import 'package:moniplan_app/i18n/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';

Future<void> main() async {
  AppLog.factory = (name) => MoniplanLog(logger: Logger(name));
  AppDi.instance = GetItAppDI();

  final zoneLog = AppLog('ZoneGuarded');

  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        Logger.root.level = Level.ALL;
        Logger.root.onRecord.listen((record) {
          if (record.loggerName == 'SuperSliverList') {
            return;
          }

          print(
            '${record.level.name}: '
            '${record.time}: '
            '${record.message} '
            '${record.error != null ? '\n${record.error}' : ''}'
            '${record.stackTrace != null ? '\n${Trace.from(record.stackTrace!)}' : ''}\n',
          );
        });
        await AppDi.instance.setup();

        initializeMessages('ru');
        initializeDateFormatting('ru');
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        final prefs = await SharedPreferences.getInstance();

        runApp(MoniplanApp(
          sharedPreferences: prefs,
        ));
      },
      (exception, stackTrace) {
        zoneLog.critical("Global error", error: exception, trace: stackTrace);
      },
    ),
  );
}
