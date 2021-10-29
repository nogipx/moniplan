import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/common/bottom_sheet.dart';
import 'package:moniplan/common/export.dart';
import 'package:moniplan/module/operation/widget/operation_list_item.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:provider/provider.dart';
import 'package:dartx/dartx.dart';

class CalendarItem extends StatefulWidget {
  final List<Operation> operations;

  const CalendarItem({Key? key, required this.operations}) : super(key: key);

  @override
  _CalendarItemState createState() => _CalendarItemState();
}

class _CalendarItemState extends State<CalendarItem> {
  late final List<Operation> _doneOperations;
  late final List<Operation> _planOperations;

  @override
  void initState() {
    final parts = widget.operations.partition((e) => e.actualValue != null);
    _doneOperations = parts[0];
    _planOperations = parts[1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_doneOperations.isNotEmpty)
          OperationWidget(
            operation: Operation.create(
              expectedValue: 0,
              actualValue: _doneOperations
                  .where((e) => e.actualValue != null)
                  .fold(0, (acc, e) => acc! + e.actualValue!),
              reason: 'Совершённые\nоперации',
              date: widget.operations.first.date,
              currency: CommonCurrencies().rub,
            ),
            onPressed: () => _showDoneOperations(context),
          ),
        ListView.separated(
          shrinkWrap: true,
          primary: false,
          itemCount: _planOperations.length,
          separatorBuilder: (context, index) => SizedBox(height: 4),
          itemBuilder: (context, index) {
            final operation = _planOperations[index];
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
                    .saveOperation(operation.copyWith(
                      enabled: !operation.enabled,
                    ));
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _showDoneOperations(BuildContext context) async {
    return showCupertinoModalBottomSheet<dynamic>(
      context: context,
      elevation: 16,
      backgroundColor: Colors.black87,
      builder: (context) {
        return BaseBottomSheet(
          expand: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Совершённые операции',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 8),
                    Text(
                      dateFormat.format(
                        widget.operations.firstOrNull?.date ?? DateTime.now(),
                      ),
                      style: Theme.of(context).textTheme.bodyText1?.apply(
                            color: AppTheme.blueColor,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                primary: false,
                itemCount: _doneOperations.length,
                separatorBuilder: (context, index) => SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final operation = _doneOperations[index];
                  return OperationWidget(
                    operation: operation,
                    onPressed: () async {
                      await OperationWidget.showPreviewSheet(
                        context: context,
                        initialData: operation,
                      ).then((value) {
                        if (value != null) {
                          context
                              .read<BudgetPredictionCubit>()
                              .saveOperation(value);
                        }
                      });
                    },
                    onToggleEnable: () {
                      context.read<BudgetPredictionCubit>().saveOperation(
                          operation.copyWith(enabled: !operation.enabled));
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
