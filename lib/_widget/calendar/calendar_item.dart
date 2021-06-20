import 'package:flutter/material.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:moniplan/_widget/export.dart';
import 'package:moniplan/bloc/budget_prediction_bloc.dart';
import 'package:provider/provider.dart';

class CalendarItem extends StatelessWidget {
  final Prediction prediction;

  const CalendarItem({Key? key, required this.prediction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final operations = prediction.operations;
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: operations.length,
          itemBuilder: (context, index) {
            final operation = operations[index];
            return OperationWidget(
              data: operation,
              onPressed: () async {
                await OperationWidget.showEdit(
                  context: context,
                  initialData: operation,
                ).then((value) {
                  if (value != null) {
                    context.read<OperationService>().save(value);
                    context
                        .read<BudgetPredictionBloc>()
                        .compute(context.read<OperationService>().getAll());
                  }
                });
              },
              onToggleEnable: () {
                context
                    .read<OperationService>()
                    .save(operation.copyWith(enabled: !operation.enabled));
                context
                    .read<BudgetPredictionBloc>()
                    .compute(context.read<OperationService>().getAll());
              },
            );
          },
        ),
      ],
    );
  }
}
