import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lan_messaging/lan_messaging.dart';
import 'package:logging/logging.dart';
import 'package:moniplan/_run/_index.dart';
import 'package:moniplan/_run/db/_index.dart';
import 'package:moniplan/core/app_log_impl.dart';
import 'package:moniplan/features/monisync/screens/monisync_screen.dart';
import 'package:moniplan/i18n/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';

Future<void> main() async {
  AppLog.factory = (name) => MoniplanLog(logger: Logger(name));
  AppDb.initializeFactory(() => AppDbImpl(encryptKey: mockEncryptionKey));

  final zoneLog = AppLog('ZoneGuarded');

  await MDnsRegistrarExt.availableLocalAddresses.then((e) async {
    print(e);
    await MDnsRegistrar(
      serviceName: 'MoniplanPixel8',
      serviceType: '_moniplan._tcp',
      targetPort: 42034,
      targetHostname: 'moniplanPixel',
      targetHost: e.first,
    ).start();
  });

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

        // init WidgetsFlutterBinding if not yet
        // final config = PostHogConfig('phc_zbkYjD7Fjn1YgHf9GiC3r9MXeRl4XtAnCOvkTB4tKOf');
        // config.debug = true;
        // config.captureApplicationLifecycleEvents = true;
        // config.host = 'https://us.i.posthog.com';
        // await Posthog().setup(config);
        // await Posthog().enable();
        // await Posthog().flush();

        await AppDb().openDefault();

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
