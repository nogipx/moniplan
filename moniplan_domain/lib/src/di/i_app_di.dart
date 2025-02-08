// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

abstract interface class IAppDi {
  Future<void> setup();

  IAppDb getDb();

  IPlannerRepo getPlannerRepo();

  IMonisyncRepo getMonisyncRepo();

  IStatisticsRepo getStatisticsRepo();
}
