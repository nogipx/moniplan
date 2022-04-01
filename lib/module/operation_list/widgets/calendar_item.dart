import 'package:dartx/dartx.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moniplan/app/app_theme.dart';
import 'package:moniplan/common/export.dart';
import 'package:moniplan/module/operation_list/operations_list_screen_wm.dart';
import 'package:moniplan/module/operation_list/widgets/create_operation_list_item.dart';
import 'package:moniplan/module/operation_list/widgets/operation_list_item.dart';
import 'package:moniplan/sdk/domain.dart';

class CalendarItem extends StatefulWidget {
  final List<Operation> operations;
  final bool showCreateOperation;
  final OperationsListScreenWM operationsListScreenWM;

  const CalendarItem({
    required this.operations,
    required this.operationsListScreenWM,
    this.showCreateOperation = false,
    Key? key,
  }) : super(key: key);

  @override
  _CalendarItemState createState() => _CalendarItemState();
}

class _CalendarItemState extends State<CalendarItem> {
  late final List<Operation> _doneOperations;
  late final List<Operation> _planOperations;

  @override
  void initState() {
    super.initState();
    final parts = widget.operations.partition((e) => e.actualValue != null);
    _doneOperations = parts[0];
    _planOperations = parts[1];
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
                  operationsListScreenWM: widget.operationsListScreenWM,
                );
              },
              onToggleEnable: () {
                widget.operationsListScreenWM.saveOperation(operation.copyWith(
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
        return EntityStateNotifierBuilder<OperationsComputeResult>(
          listenableEntityState: widget.operationsListScreenWM.result,
          builder: (context, data) {
            final doneOperations = data?.operationsByDay[day]
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
                        const SizedBox(height: 8),
                        Text(
                          dateFormat.format(day),
                          style: Theme.of(context).textTheme.bodyText1?.apply(
                                color: AppTheme.blueColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: doneOperations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final operation = doneOperations[index];
                      return OperationWidget(
                        operation: operation,
                        onPressed: () async {
                          await OperationWidget.showPreviewSheet(
                            context: context,
                            initialData: operation,
                            operationsListScreenWM:
                                widget.operationsListScreenWM,
                          ).then((value) {
                            if (value != null) {
                              widget.operationsListScreenWM
                                  .saveOperation(value);
                            }
                          });
                        },
                        onToggleEnable: () {
                          widget.operationsListScreenWM.saveOperation(
                            operation.copyWith(enabled: !operation.enabled),
                          );
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
    return CreateOperationListItem(
      onPressed: () async {
        await OperationWidget.showEdit(
          context: context,
        );
      },
    );
  }
}
