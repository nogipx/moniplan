import 'package:flutter/material.dart';
import 'package:moniplan/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/widget/calendar_widget.dart';
import 'package:moniplan/widget/operation_list_item.dart';
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
    predictionBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onDoubleTap: () {
            OperationWidget.showEdit(context: context).then((value) {
              if (value != null) {
                predictionBloc.saveOperation(value);
              }
            });
          },
          child: Builder(
            builder: (context) {
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
      ),
    );
  }
}
