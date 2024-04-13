import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moniplan/app.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'objectbox.dart';

late ObjectBox objectbox;
late Admin admin;

Future<void> main() async {
  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        objectbox = await ObjectBox.create();
        if (Admin.isAvailable()) {
          // Keep a reference until no longer needed or manually closed.
          admin = Admin(objectbox.store);
        }

        initializeDateFormatting('ru');
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        // SystemChrome.setSystemUIOverlayStyle(lightSystemUIOverlay);
        final prefs = await SharedPreferences.getInstance();

        runApp(MoniplanApp(
          sharedPreferences: prefs,
        ));
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
