import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moniplan/_run/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

late MoniplanDriftDb db;

MoniplanDriftDb get actualDb => db;

Future<void> main() async {
  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        Logger.root.level = Level.ALL;
        Logger.root.onRecord.listen((record) {
          print(
            '${record.level.name}: '
            '${record.time}: '
            '${record.message} '
            '${record.error != null ? '\n${record.error}' : ''}'
            '${record.stackTrace != null ? '\n${Trace.from(record.stackTrace!)}' : ''}\n',
          );
        });

        db = MoniplanDriftDb(
          dbExecutor: driftOpenDefault(),
        );

        initializeDateFormatting('ru');
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        // SystemChrome.setSystemUIOverlayStyle(lightSystemUIOverlay);
        final prefs = await SharedPreferences.getInstance();
        // await _clear();
        // await _savePlanner(currentRequest);

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

_savePlanner(Planner planner) async {
  // final generated = GenerateNewPlannerUseCase(
  //   args: GenerateNewPlannerUseCaseArgs(
  //     payments: planner.payments,
  //     dateStart: planner.dateStart,
  //     dateEnd: planner.dateEnd,
  //     initialBudget: planner.initialBudget,
  //   ),
  // ).run();

  final repo = PlannerRepoDrift(db: db);
  await repo.savePlanner(planner);
}
