import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/common/bottom_sheet.dart';
import 'package:moniplan/module/operation/common/currency_colored.dart';
import 'package:moniplan/sdk/domain.dart';

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
                ),
                SizedBox(height: 8),
                if (operation.actualValue != null)
                  _buildMoneyRow(
                    context,
                    title: 'Фактическая сумма',
                    value: operation.actualValue!,
                  ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildAction(
                  context,
                  icon: Icon(Icons.edit),
                  title: 'Изменить',
                  action: () {},
                ),
              ),
              Expanded(
                child: _buildAction(
                  context,
                  icon: Icon(Icons.edit),
                  title: 'Изменить',
                  action: () {},
                ),
              ),
              Expanded(
                child: _buildAction(
                  context,
                  icon: Icon(
                    Icons.power_settings_new_rounded,
                    color: operation.enabled
                        ? Colors.white
                        : AppTheme.primaryTextColor,
                  ),
                  title: operation.enabled ? 'Не учитывать' : 'Учитывать',
                  action: () {},
                  enabled: operation.enabled,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMoneyRow(BuildContext context,
      {required String title, required double value}) {
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
          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 14),
        )
      ],
    );
  }
}
