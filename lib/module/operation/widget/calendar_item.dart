import 'package:flutter/material.dart';
import 'package:moniplan/module/operation/widget/operation_list_item.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:provider/provider.dart';

class CalendarItem extends StatelessWidget {
  final List<Operation> operations;

  const CalendarItem({Key? key, required this.operations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      primary: false,
      itemCount: operations.length,
      separatorBuilder: (context, index) => SizedBox(height: 4),
      itemBuilder: (context, index) {
        final operation = operations[index];
        return OperationWidget(
          operation: operation,
          onPressed: () async {
            await OperationWidget.showPreviewSheet(
              context: context,
              initialData: operation,
            ).then((value) {
              if (value != null) {
                context.read<BudgetPredictionCubit>().saveOperation(value);
              }
            });
          },
          onToggleEnable: () {
            context
                .read<BudgetPredictionCubit>()
                .saveOperation(operation.copyWith(enabled: !operation.enabled));
          },
        );
      },
    );
  }
}
