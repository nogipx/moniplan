import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/common/export.dart';
import 'package:moniplan/module/operation/export.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:provider/provider.dart';
import 'package:dartx/dartx.dart';

class CalendarItem extends StatefulWidget {
  const CalendarItem({
    Key? key,
    required this.operations,
    this.showCreateOperation = false,
  }) : super(key: key);

  final List<Operation> operations;
  final bool showCreateOperation;

  @override
  _CalendarItemState createState() => _CalendarItemState();
}

class _CalendarItemState extends State<CalendarItem> {
  late final List<Operation> _doneOperations;
  late final List<Operation> _planOperations;
  late final BudgetPredictionCubit _predictionCubit;

  @override
  void initState() {
    final parts = widget.operations.partition((e) => e.actualValue != null);
    _doneOperations = parts[0];
    _planOperations = parts[1];
    _predictionCubit = context.read<BudgetPredictionCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: _planOperations.length,
          itemBuilder: (context, index) {
            final operation = _planOperations[index];
            return OperationWidget(
              operation: operation,
              onPressed: () async {
                await OperationWidget.showPreviewSheet(
                  context: context,
                  initialData: operation,
                );
              },
              onToggleEnable: () {
                _predictionCubit.saveOperation(operation.copyWith(
                  enabled: !operation.enabled,
                ));
              },
            );
          },
        ),
        if (widget.showCreateOperation) _buildCreateOperation(),
        if (_doneOperations.isNotEmpty)
          OperationWidget(
            operation: Operation.create(
              expectedValue: 0,
              actualValue: _doneOperations
                  .where((e) => e.enabled && e.actualValue != null)
                  .fold(0, (acc, e) => acc! + e.actualValue!),
              reason: 'Завершённые\nоперации',
              date: widget.operations.first.date,
              currency: CommonCurrencies().rub,
            ),
            onPressed: () => _showDoneOperations(context),
          ),
      ],
    );
  }

  Future<void> _showDoneOperations(BuildContext context) async {
    final day = widget.operations.firstOrNull?.date.date ?? DateTime.now().date;
    return showCupertinoModalBottomSheet<dynamic>(
      context: context,
      animationCurve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 250),
      backgroundColor: Colors.black87,
      builder: (context) {
        return BlocBuilder<BudgetPredictionCubit, BudgetPredictionState>(
          builder: (context, state) {
            final _doneOperations = _predictionCubit.operationsByDay[day]
                    ?.where((e) => e.actualValue != null)
                    .toList() ??
                [];
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
                          'Завершённые операции',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        SizedBox(height: 8),
                        Text(
                          dateFormat.format(day),
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
      },
    );
  }

  Widget _buildCreateOperation() {
    return CreateOperationItem(
      onPressed: () async {
        await OperationWidget.showEdit(
          context: context,
        );
      },
    );
  }
}
