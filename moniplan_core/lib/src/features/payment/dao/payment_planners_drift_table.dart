import 'package:drift/drift.dart';

@TableIndex(name: 'index_planner_id', columns: {#plannerId})
class PaymentPlannersDriftTable extends Table {
  @override
  Set<Column> get primaryKey => {plannerId};

  /// Id section
  ///
  TextColumn get plannerId => text()();

  /// Money section
  ///
  RealColumn get initialBudget => real().withDefault(const Constant(0.0))();

  /// Status section
  ///
  BoolColumn get isDraft => boolean().withDefault(const Constant(false))();

  /// Dates section
  ///
  DateTimeColumn get dateStart => dateTime().nullable()();
  DateTimeColumn get dateEnd => dateTime().nullable()();
}
