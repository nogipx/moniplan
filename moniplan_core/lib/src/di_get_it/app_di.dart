// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_core/moniplan_core.dart';

abstract class AppDi implements IAppDi {
  static late final AppDi instance;

  @override
  AppDb getDb();
}
