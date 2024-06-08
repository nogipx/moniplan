import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moniplan/_run/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'our_budget/_index.dart';

late MoniplanDriftDb db;
const testPlannerId = '5778fa84-2a3f-4c3d-b617-3ed5272e0ed2';

Future<void> main() async {
  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        db = await MoniplanDriftDb(
          lazyDatabase: driftOpenConnection(),
        );

        initializeDateFormatting('ru');
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        // SystemChrome.setSystemUIOverlayStyle(lightSystemUIOverlay);
        final prefs = await SharedPreferences.getInstance();
        await _clear();
        await _savePlanner(currentRequest);

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

_clear() async {
  await db.managers.paymentPlannersDriftTable.delete();
  await db.managers.paymentsComposedDriftTable.delete();
}

_savePlanner(PaymentPlanner planner) async {
  final generated = GeneratePlannerUseCase(
    args: GeneratePlannerUseCaseArgs(
      payments: planner.payments,
      dateStart: planner.dateStart,
      dateEnd: planner.dateEnd,
      initialBudget: planner.initialBudget,
    ),
  ).run();

  final repo = PaymentPlannerRepoDrift(db: db);
  await repo.persistPlanner(generated.planner);
}
