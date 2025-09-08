// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_app/_run/db/_index.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/domain/lib/moniplan_domain.dart';
import 'package:moniplan_app/features/monisync/repo/i_manual_monisync_repo.dart';

abstract interface class IAppDi {
  Future<void> setup();

  IAppDb getDb();

  IPlannerRepo getPlannerRepo();

  Future<IMonisyncRepo> getMonisyncRepo();

  IStatisticsRepo getStatisticsRepo();

  IMoniplanLicenseRepo getLicenseRepo();

  IFeaturesManager getFeaturesManager();
}

abstract class AppDi implements IAppDi {
  static late final AppDi instance;

  @override
  AppDb getDb();

  T get<T extends Object>();
}
