import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moniplan/bloc/budget_prediction_bloc.dart';
import 'package:moniplan/screen/layout/dashboard_layout.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:moniplan/_widget/export.dart';
import 'package:provider/provider.dart';

class OperationsScreenMob extends StatefulWidget {
  const OperationsScreenMob({Key? key}) : super(key: key);
  @override
  _OperationsScreenMobState createState() => _OperationsScreenMobState();
}

class _OperationsScreenMobState extends State<OperationsScreenMob> {
  late final BudgetPredictionBloc predictionBloc;
  late final OperationService operationService;

  @override
  void initState() {
    operationService = context.read<OperationService>();
    predictionBloc = context.read<BudgetPredictionBloc>();
    super.initState();
  }

  @override
  void dispose() {
    predictionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      appBar: AppBar(
        title: const Text('Moniplan'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await OperationWidget.showEdit(
            context: context,
          ).then((value) {
            setState(() {
              if (value != null) {
                context.read<OperationService>().save(value);
                context
                    .read<BudgetPredictionBloc>()
                    .compute(context.read<OperationService>().getAll());
              }
            });
          });
        },
      ),
      drawer: Container(color: Colors.green),
      content: ValueListenableBuilder(
        valueListenable: Hive.box<Operation>(OperationService.key).listenable(),
        builder: (context, box, widget) {
          final operations = operationService.getAll();
          return OperationsListWidget(
            eventsByDay: predictionBloc.predictBudgetByDay(operations),
          );
        },
      ),
    );
  }
}
