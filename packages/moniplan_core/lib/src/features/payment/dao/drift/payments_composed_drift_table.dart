import 'package:drift/drift.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PaymentsComposedDriftTable extends Table {
  /// Id section
  ///
  IntColumn get id => integer().autoIncrement()();
  TextColumn get paymentId => text().unique()();
  TextColumn get plannerId => text().nullable()();
  TextColumn get originalPaymentId => text().nullable()();

  /// Description section
  ///
  TextColumn get paymentName => text().withDefault(const Constant(''))();
  TextColumn get paymentNote => text().withDefault(const Constant(''))();

  /// Money section
  ///
  RealColumn get paymentMoney => real().withDefault(const Constant(0.0))();
  IntColumn get paymentTypeId => integer().withDefault(const Constant(0))();
  TextColumn get currencyCode => text().nullable()();
  IntColumn get currencyPrecision => integer().nullable()();

  /// Status section
  ///
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();

  /// Dates section
  ///
  IntColumn get dateTimeRepeatId => integer().withDefault(const Constant(0))();
  DateTimeColumn get date => dateTime().nullable()();
  DateTimeColumn get dateMoneyReserved => dateTime().nullable()();
  DateTimeColumn get dateStart => dateTime().nullable()();
  DateTimeColumn get dateEnd => dateTime().nullable()();
}
