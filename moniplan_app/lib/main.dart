// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_app/_run/log/console_log.dart';
import 'package:moniplan_app/i18n/_index.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';

Future<void> main() async {
  AppLog.factory = (name) => ConsoleAppLog(name);
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
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        final prefs = await SharedPreferences.getInstance();

        runApp(MoniplanApp(sharedPreferences: prefs));
      },
      (exception, stackTrace) {
        zoneLog.critical("Global error", error: exception, trace: stackTrace);
      },
    ),
  );
}
