import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/moniplan_db.dart';

part 'drift_database.g.dart';

typedef DriftDbConnector = LazyDatabase Function();

@DriftDatabase(
  tables: [
    GlobalLastUpdate,
    PaymentPlannersDriftTable,
    PaymentsComposedDriftTable,
    PlannerActualInfoDriftTable,
  ],
)
class MoniplanDriftDb extends _$MoniplanDriftDb {
  final QueryExecutor dbExecutor;

  MoniplanDriftDb({required this.dbExecutor}) : super(dbExecutor);

  @override
  int get schemaVersion => 7;

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
        if (from < 4) {
          await m.createTable(plannerActualInfoDriftTable);
        }
        if (from < 5) {
          // await m.addColumn(
          //   plannerActualInfoDriftTable,
          //   plannerActualInfoDriftTable.updatedAtBudget,
          // );
        }
        if (from < 6) {
          await m.createTable(globalLastUpdate);
        }
        if (from < 7) {
          await m.addColumn(paymentPlannersDriftTable, paymentPlannersDriftTable.plannerName);
        }
      },
    );
  }
}
