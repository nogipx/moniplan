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
  final mapper = PlannerMapper();
  final generated = GeneratePlannerUseCase(
    args: GeneratePlannerUseCaseArgs(
      payments: currentRequest.payments,
      dateStart: currentRequest.dateStart,
      dateEnd: currentRequest.dateEnd,
      initialBudget: currentRequest.initialBudget,
    ),
  ).run();

  final dao = mapper.toDto(generated.planner);
  objectbox.store.box<PaymentPlannerDaoOB>().put(dao);
}

PaymentPlanner? getPlanner(String id) {
  final mapper = PlannerMapper();
  final dao = objectbox.store
      .box<PaymentPlannerDaoOB>()
      .query(
        PaymentPlannerDaoOB_.plannerId.equals(id),
      )
      .build()
      .findUnique();

  if (dao != null) {
    final planner = mapper.toDomain(dao);
    return planner;
  }
  return null;
}
