// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

abstract class AppDi implements IAppDi {
  static late final AppDi instance;

  @override
  AppDb getDb();

  @override
  LicenseFeaturesService getLicenseFeaturesService();

  T get<T extends Object>();
}
