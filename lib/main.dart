import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moniplan/app/injector.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/app/export.dart';
import 'package:moniplan/sdk/hive/currency_adapter.dart';

import 'app/theme.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(lightSystemUIOverlay);

    await initHive();
    Hive.registerAdapter(CurrencyAdapter());
    Hive.registerAdapter(OperationAdapter());
    await initializeDateFormatting('ru');

    runApp(
      ProviderScope(
        child: Injector(
          operationHive: await Hive.openBox<Operation>(OperationService.key),
          child: const Moniplan(),
        ),
      ),
    );
  }, (exception, stackTrace) {
    print(exception);
    print(stackTrace);
  });
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(OperationAdapter());
  Hive.registerAdapter(CurrencyAdapter());
}
