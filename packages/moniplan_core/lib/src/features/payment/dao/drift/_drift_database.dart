import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/moniplan_db.dart';

part '_drift_database.g.dart';

typedef DriftDbConnector = LazyDatabase Function();

@DriftDatabase(
  tables: [
    PaymentPlannersDriftTable,
    PaymentsComposedDriftTable,
  ],
)
class MoniplanDriftDb extends _$MoniplanDriftDb {
  final LazyDatabase lazyDatabase;

  MoniplanDriftDb({required this.lazyDatabase}) : super(lazyDatabase);

  @override
  int get schemaVersion => 1;
}
