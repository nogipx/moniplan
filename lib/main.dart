import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moniplan/app/export.dart';
import 'package:moniplan/sdk/domain.dart';

Future<void> main() async {
  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setSystemUIOverlayStyle(lightSystemUIOverlay);

        await initHive();
        await initializeDateFormatting('ru');

        runApp(const MoniplanResponsiveApp());
      },
      (exception, stackTrace) {
        if (kDebugMode) {
          print(exception);
        }
        if (kDebugMode) {
          print(stackTrace);
        }
      },
    ),
  );
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive
    ..registerAdapter(OperationAdapter())
    ..registerAdapter(CurrencyAdapter());
}
