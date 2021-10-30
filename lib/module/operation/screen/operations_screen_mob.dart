import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/module/operation/widget/calendar_widget.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:provider/provider.dart';

class OperationsScreenMob extends StatefulWidget {
  const OperationsScreenMob({Key? key}) : super(key: key);
  @override
  _OperationsScreenMobState createState() => _OperationsScreenMobState();
}

class _OperationsScreenMobState extends State<OperationsScreenMob> {
  late final BudgetPredictionCubit predictionBloc;
  late final OperationService operationService;

  @override
  void initState() {
    operationService = context.read<OperationService>();
    predictionBloc = context.read<BudgetPredictionCubit>();
    super.initState();
  }

  @override
  void dispose() {
    predictionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable:
              Hive.box<Operation>(OperationService.key).listenable(),
          builder: (context, box, widget) {
            final predictionState = predictionBloc.state;
            if (predictionState is PredictionSuccess) {
              return OperationsListWidget(
                eventsByDay: predictionState.operations,
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
