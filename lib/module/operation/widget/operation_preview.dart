import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/common/widget/export.dart';
import 'package:moniplan/module/operation/export.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartx/dartx.dart';
import 'package:moniplan/common/export.dart';

class OperationPreview extends StatefulWidget {
  final Operation operation;

  const OperationPreview({Key? key, required this.operation}) : super(key: key);

  @override
  _OperationPreviewState createState() => _OperationPreviewState();
}

class _OperationPreviewState extends State<OperationPreview> {
  late Operation _operation = widget.operation;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BudgetPredictionCubit, BudgetPredictionState>(
      listener: (context, state) {
        if (state is PredictionSuccess) {
          _operation =
              state.operations[widget.operation.date.date]?.singleWhere(
                    (e) => e.id == widget.operation.id,
                    orElse: () => widget.operation,
                  ) ??
                  widget.operation;
        } else {
          _operation = widget.operation;
        }
      },
      builder: (context, state) {
        return BaseBottomSheet(
          expand: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _operation.reason.isNotEmpty
                          ? _operation.reason
                          : 'Название',
                      style: Theme.of(context).textTheme.subtitle2?.copyWith(
                            color: _operation.reason.isNotEmpty
                                ? AppTheme.primaryTextColor
                                : AppTheme.inactiveTextColor,
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      DateFormat(DateFormat.MONTH_DAY, 'ru')
                          .format(_operation.date),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.apply(color: AppTheme.lightBlueColor),
                    ),
                    SizedBox(height: 32),
                    _buildMoneyRow(
                      context,
                      title: 'Планируемая сумма',
                      value: _operation.expectedValue,
                      enabled:
                          _operation.enabled && _operation.actualValue == null,
                    ),
                    SizedBox(height: 8),
                    if (_operation.actualValue != null)
                      _buildMoneyRow(
                        context,
                        title: 'Фактическая сумма',
                        value: _operation.actualValue!,
                        enabled: _operation.enabled &&
                            _operation.actualValue != null,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildAction(
                      context,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: closeColor,
                      ),
                      title: 'Удалить',
                      action: () async {
                        await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return ConfirmDialog(
                              title: 'Удаление операции',
                              approveText: 'Удалить',
                            );
                          },
                        ).then((confirm) async {
                          if (confirm ?? false) {
                            await context
                                .read<BudgetPredictionCubit>()
                                .deleteOperation(widget.operation);
                            Navigator.of(context).pop();
                          }
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildAction(
                      context,
                      icon: _operation.actualValue == null
                          ? Icon(
                              Icons.check_rounded,
                              color: AppTheme.blueColor,
                            )
                          : Text(
                              _operation.currency.symbol,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: AppTheme.blueColor,
                                  ),
                            ),
                      title: _operation.actualValue == null
                          ? 'Завершить'
                          : 'Изменить',
                      action: () => _actionChangeMoney(context),
                    ),
                  ),
                  Expanded(
                    child: _buildAction(
                      context,
                      icon: Icon(Icons.power_settings_new_rounded,
                          color: _operation.enabled
                              ? Colors.white
                              : AppTheme.blueColor),
                      title: _operation.enabled ? 'Не учитывать' : 'Учитывать',
                      enabled: _operation.enabled,
                      action: () async {
                        await context
                            .read<BudgetPredictionCubit>()
                            .saveOperation(_operation.copyWith(
                              enabled: !_operation.enabled,
                            ));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SecondaryActionButton(
                  text: 'Редактировать',
                  onTap: () {
                    OperationWidget.showEdit(
                      context: context,
                      initialData: _operation,
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoneyRow(
    BuildContext context, {
    required String title,
    required double value,
    bool enabled = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(width: 12),
        MoneyColoredWidget(
          currency: CommonCurrencies().rub,
          value: value,
          showPlusSign: false,
          overrideColor: enabled ? null : AppTheme.inactiveTextColor,
        )
      ],
    );
  }

  Widget _buildAction(
    BuildContext context, {
    required String title,
    required Widget icon,
    VoidCallback? action,
    bool enabled = false,
  }) {
    return Column(
      children: [
        Material(
          color: enabled
              ? AppTheme.lightBlueColor
              : AppTheme.inactiveBackgroundColor,
          shape: CircleBorder(),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: action,
            child: Container(
              height: 70,
              width: 70,
              alignment: Alignment.center,
              child: icon,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 14),
        )
      ],
    );
  }

  Future<void> _actionChangeMoney(BuildContext context) async {
    final editCubit = OperationEditCubit(initial: _operation);
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<OperationEditCubit, OperationEditState>(
          bloc: editCubit,
          builder: (context, state) {
            return ConfirmDialog(
              title: 'Изменение суммы',
              approveText: 'Готово',
              approveValidator: () => editCubit.isValid,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: EditMoneyWidget(
                  editCubit: editCubit,
                  initialTab: EditMoneyTab.Actual,
                  autofocus: true,
                ),
              ),
            );
          },
        );
      },
    ).then((confirm) {
      if (confirm ?? false) {
        context
            .read<BudgetPredictionCubit>()
            .saveOperation(editCubit.operation);
      }
    });
  }
}
