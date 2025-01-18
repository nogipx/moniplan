// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:moniplan_core/moniplan_db.dart';

class GlobalLastUpdate extends Table {
  static const entityId = 'global_last_update';

  @override
  Set<Column> get primaryKey => {lastUpdateId};

  TextColumn get lastUpdateId => text().withDefault(const Constant('global_last_update'))();
  DateTimeColumn get updatedAt => dateTime()();
}
