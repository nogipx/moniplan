import 'package:drift/drift.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PaymentPlannersDriftTable extends Table {
  /// Id section
  ///
  IntColumn get id => integer().autoIncrement()();
  TextColumn get plannerId => text().unique()();

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
