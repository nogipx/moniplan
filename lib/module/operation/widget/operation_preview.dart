import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/common/bottom_sheet.dart';
import 'package:moniplan/common/buttons.dart';
import 'package:moniplan/common/confirm_dialog_builder.dart';
import 'package:moniplan/module/operation/common/currency_colored.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/module/operation/widget/operation_list_item.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OperationPreview extends StatelessWidget {
  final Operation operation;

  const OperationPreview({Key? key, required this.operation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  operation.reason.isNotEmpty ? operation.reason : 'Название',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        color: operation.reason.isNotEmpty
                            ? AppTheme.primaryTextColor
                            : AppTheme.inactiveTextColor,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  DateFormat(DateFormat.MONTH_DAY, 'ru').format(operation.date),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.apply(color: AppTheme.lightBlueColor),
                ),
                SizedBox(height: 32),
                _buildMoneyRow(
                  context,
                  title: 'Планируемая сумма',
                  value: operation.expectedValue,
                  enabled: operation.enabled && operation.actualValue == null,
                ),
                SizedBox(height: 8),
                if (operation.actualValue != null)
                  _buildMoneyRow(
                    context,
                    title: 'Фактическая сумма',
                    value: operation.actualValue!,
                    enabled: operation.enabled && operation.actualValue != null,
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
                            .deleteOperation(operation);
                        Navigator.of(context).pop();
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: _buildAction(
                  context,
                  icon: Icon(Icons.check_rounded, color: AppTheme.blueColor),
                  title: 'Завершить',
                  action: () {},
                ),
              ),
              Expanded(
                child: _buildAction(
                  context,
                  icon: Icon(Icons.power_settings_new_rounded,
                      color: operation.enabled
                          ? Colors.white
                          : AppTheme.blueColor),
                  title: operation.enabled ? 'Не учитывать' : 'Учитывать',
                  enabled: operation.enabled,
                  action: () async {
                    await context
                        .read<BudgetPredictionCubit>()
                        .saveOperation(operation.copyWith(
                          enabled: !operation.enabled,
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
                  initialData: operation,
                );
              },
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
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
        CurrencyColorWidget(
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
}
