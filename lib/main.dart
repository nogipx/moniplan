import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moniplan/app/injector.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/app/export.dart';

import 'app/theme.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(lightSystemUIOverlay);

    // Hive.registerAdapter(OperationTypeAdapter());
    Hive.registerAdapter(OperationAdapter());
    // Hive.registerAdapter<Prediction>(PredictionAdapter());
    await Hive.initFlutter();

    await initializeDateFormatting('ru');
    runApp(
      Injector(
        operationHive: await Hive.openBox<Operation>(OperationService.key),
        child: MoniplanResponsiveApp(),
      ),
    );
  }, (exception, stackTrace) {
    print(exception);
    print(stackTrace);
  });
}
