import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/common/util/export.dart';
import 'package:moniplan/module/operation/cubit/operation_edit_cubit.dart';
import 'package:moniplan/module/operation/export.dart';

class OperationWidget extends StatelessWidget {
  final Operation operation;
  final VoidCallback? onPressed;
  final VoidCallback? onToggleEnable;

  const OperationWidget({
    Key? key,
    required this.operation,
    this.onPressed,
    this.onToggleEnable,
  }) : super(key: key);

  Widget _buildToggleEnable() {
    return IconButton(
      constraints: BoxConstraints.tightFor(),
      padding: const EdgeInsets.all(0),
      splashRadius: 20,
      icon: Icon(
        operation.enabled
            ? Icons.check_box_outlined
            : Icons.indeterminate_check_box_outlined,
        color: operation.enabled ? Colors.green : Colors.grey,
      ),
      onPressed: onToggleEnable ?? () {},
    );
  }

  Widget _buildReason(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMMd().format(operation.date),
          style: Theme.of(context).textTheme.caption?.apply(
                color: secondaryTextColor,
              ),
        ),
        SizedBox(height: 4),
        Text(
          operation.reason,
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(fontWeight: FontWeight.bold, color: primaryTextColor),
        )
      ],
    );
  }

  Widget _buildBudgetValue(BuildContext context) {
    final hintStyle = Theme.of(context).textTheme.caption?.copyWith(
          fontSize: 11,
          color: secondaryTextColor,
        );
    if (operation.actualValue != null) {
      return Column(
        children: [
          Text("Фактическая сумма", style: hintStyle),
          SizedBox(height: 4),
          CurrencyColorWidget(
            value: operation.actualValue,
            overrideColor: !operation.enabled ? Colors.grey : null,
            currency: CommonCurrencies().rub,
            textStyle: Theme.of(context).textTheme.subtitle1,
          )
        ],
      );
    } else {
      return Column(
        children: [
          Text("Ожидаемая сумма", style: hintStyle),
          SizedBox(height: 4),
          CurrencyColorWidget(
            value: operation.expectedValue,
            overrideColor: !operation.enabled || operation.actualValue != null
                ? Colors.grey
                : null,
            currency: CommonCurrencies().rub,
            textStyle: Theme.of(context).textTheme.subtitle1,
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Grayscale(
      grayscale: !operation.enabled,
      child: Card(
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildReason(context),
                  ),
                  SizedBox(width: 8),
                  _buildBudgetValue(context),
                  VerticalDivider(width: 24),
                  Align(
                    alignment: Alignment.center,
                    child: _buildToggleEnable(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<Operation?> showEdit({
    required BuildContext context,
    Operation? initialData,
  }) async {
    final result = await showDialog<Operation?>(
      barrierColor: Colors.black38,
      context: context,
      builder: (context) {
        return SizedBox(
          width: 330,
          child: AlertDialog(
            content: OperationEditWidget(
              operationEditCubit: OperationEditCubit(
                initial: initialData,
              ),
            ),
          ),
        );
      },
    );
    return result;
  }
}
