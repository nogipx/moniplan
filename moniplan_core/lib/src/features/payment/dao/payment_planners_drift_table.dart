import 'package:drift/drift.dart';

@TableIndex(name: 'index_planner_id', columns: {#plannerId})
class PaymentPlannersDriftTable extends Table {
  @override
  Set<Column> get primaryKey => {plannerId};

  /// Id section
  ///
  TextColumn get plannerId => text()();
  TextColumn get plannerName => text().withDefault(const Constant(''))();

  /// Money section
  ///
  RealColumn get initialBudget => real().withDefault(const Constant(0.0))();

  /// Status section
  ///
  BoolColumn get isGenerationAllowed => boolean().withDefault(const Constant(true))();

  /// Dates section
  ///
  DateTimeColumn get dateStart => dateTime().nullable()();
  DateTimeColumn get dateEnd => dateTime().nullable()();
}
