import 'package:drift/drift.dart';
import 'package:moniplan_core/moniplan_db.dart';

@TableIndex(name: 'index_planner_id_actual_info', columns: {#plannerId})
class PaymentPlannersDriftTable extends Table {
  @override
  Set<Column> get primaryKey => {plannerId};

  TextColumn get plannerId => text()();
  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get completedCount => integer().withDefault(const Constant(0))();
  IntColumn get waitingCount => integer().withDefault(const Constant(0))();
  IntColumn get disabledCount => integer().withDefault(const Constant(0))();
  IntColumn get totalCount => integer().withDefault(const Constant(0))();

  TextColumn get budgetSeries => text().withDefault(const Constant('[]'))();
}
