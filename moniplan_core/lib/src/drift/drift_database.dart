import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/moniplan_db.dart';

part 'drift_database.g.dart';

typedef DriftDbConnector = LazyDatabase Function();

@DriftDatabase(
  tables: [
    PaymentPlannersDriftTable,
    PaymentsComposedDriftTable,
  ],
)
class MoniplanDriftDb extends _$MoniplanDriftDb {
  final QueryExecutor lazyDatabase;

  MoniplanDriftDb({required this.lazyDatabase}) : super(lazyDatabase);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(paymentsComposedDriftTable, paymentsComposedDriftTable.paymentTags);
          await m.addColumn(paymentsComposedDriftTable, paymentsComposedDriftTable.paymentTax);
        }
        if (from < 3) {
          await m.renameColumn(
            paymentPlannersDriftTable,
            'is_draft',
            paymentPlannersDriftTable.isGenerationAllowed,
          );
        }
      },
    );
  }
}
