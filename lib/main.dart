import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'our_budget/_index.dart';

late ObjectBox objectbox;
late Admin admin;
const testPlannerId = '5778fa84-2a3f-4c3d-b617-3ed5272e0ed2';

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

_clear() {
  objectbox.store.box<PaymentComposedDaoOB>().removeAll();
  objectbox.store.box<PaymentPlannerDaoOB>().removeAll();
}

_savePlanner(PaymentPlanner planner) {
  final mapper = PlannerMapperOB();
  final generated = GeneratePlannerUseCase(
    args: GeneratePlannerUseCaseArgs(
      payments: planner.payments,
      dateStart: planner.dateStart,
      dateEnd: planner.dateEnd,
      initialBudget: planner.initialBudget,
    ),
  ).run();

  final dao = mapper.toDto(generated.planner);
  objectbox.store.box<PaymentPlannerDaoOB>().put(dao);
}
