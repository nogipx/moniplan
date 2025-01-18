// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:moniplan_core/moniplan_db.dart';

class PlannerActualInfoDriftTable extends Table {
  @override
  Set<Column> get primaryKey => {plannerId};

  TextColumn get plannerId => text()();
  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get completedCount => integer().withDefault(const Constant(0))();
  IntColumn get waitingCount => integer().withDefault(const Constant(0))();
  IntColumn get disabledCount => integer().withDefault(const Constant(0))();
  IntColumn get totalCount => integer().withDefault(const Constant(0))();
  RealColumn get updatedAtBudget => real().withDefault(const Constant(0))();
}
