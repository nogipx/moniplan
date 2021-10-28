import 'package:flutter/material.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/module/operation/export.dart';
import 'package:provider/provider.dart';

class CalendarItem extends StatelessWidget {
  final Prediction prediction;

  const CalendarItem({Key? key, required this.prediction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final operations = prediction.operations;
    return ListView.separated(
      shrinkWrap: true,
      primary: false,
      itemCount: operations.length,
      separatorBuilder: (context, index) => SizedBox(height: 4),
      itemBuilder: (context, index) {
        final operation = operations[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OperationWidget(
            operation: operation,
            onPressed: () async {
              await OperationWidget.showEdit(
                context: context,
                initialData: operation,
              ).then((value) {
                if (value != null) {
                  context.read<OperationService>().save(value);
                  context.read<BudgetPredictionCubit>().predictBudgetByDays(
                      context.read<OperationService>().getAll());
                }
              });
            },
            onToggleEnable: () {
              context
                  .read<OperationService>()
                  .save(operation.copyWith(enabled: !operation.enabled));
              context.read<BudgetPredictionCubit>().predictBudgetByDays(
                  context.read<OperationService>().getAll());
            },
          ),
        );
      },
    );
  }
}
