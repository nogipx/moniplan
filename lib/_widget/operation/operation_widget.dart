import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:moniplan/_widget/export.dart';
import 'package:moniplan/_widget/util/grayscale.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:responsive_framework/responsive_value.dart';

class OperationWidget extends StatelessWidget {
  final Operation data;
  final VoidCallback? onPressed;
  final VoidCallback? onToggleEnable;

  const OperationWidget({
    Key? key,
    required this.data,
    this.onPressed,
    this.onToggleEnable,
  }) : super(key: key);

  Widget _buildToggleEnable() {
    return IconButton(
      constraints: BoxConstraints.tightFor(),
      padding: const EdgeInsets.all(0),
      splashRadius: 20,
      icon: Icon(
        data.enabled
            ? Icons.check_box_outlined
            : Icons.indeterminate_check_box_outlined,
        color: data.enabled ? Colors.green : Colors.grey,
      ),
      onPressed: onToggleEnable ?? () {},
    );
  }

  Widget _buildReason(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMMd().format(data.date),
          style: Theme.of(context).textTheme.caption,
        ),
        SizedBox(height: 4),
        Text(
          data.reason,
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        )
      ],
    );
  }

  Widget _buildBudgetValue(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ResponsiveVisibility(
          visibleWhen: const [
            Condition<dynamic>.largerThan(breakpoint: 500),
          ],
          child: Column(
            children: [
              Text(
                "Ожидаемая сумма",
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: 4),
              CurrencyColorWidget(
                value: data.expectedValue,
                overrideColor: !data.enabled || data.actualValue != null
                    ? Colors.grey
                    : null,
                currency: CommonCurrencies().rub,
                textStyle: Theme.of(context).textTheme.subtitle1,
              )
            ],
          ),
        ),
        SizedBox(width: 32),
        ResponsiveVisibility(
          visible: data.actualValue != null,
          visibleWhen: const [
            Condition<dynamic>.largerThan(breakpoint: 500),
          ],
          child: Column(
            children: [
              Text(
                "Фактическая сумма",
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: 4),
              CurrencyColorWidget(
                value: data.actualValue,
                overrideColor: !data.enabled ? Colors.grey : null,
                currency: CommonCurrencies().rub,
                textStyle: Theme.of(context).textTheme.subtitle1,
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Grayscale(
      grayscale: !data.enabled,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    flex: 35,
                    child: Row(
                      children: [
                        _buildToggleEnable(),
                        VerticalDivider(width: 24),
                        Expanded(
                          child: _buildReason(context),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(width: 24),
                  Expanded(
                    flex: 65,
                    child: _buildBudgetValue(context),
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
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(16),
      //     topRight: Radius.circular(16),
      //   ),
      // ),
      // backgroundColor: Colors.grey,
      // // expand: true,
      // useRootNavigator: true,
      // duration: Duration(milliseconds: 250),
      // enableDrag: true,
      context: context,
      builder: (context) {
        return SizedBox(
          width: 330,
          child: AlertDialog(
            content: OperationEditWidget(initialData: initialData),
          ),
        );
      },
    );
    return result;
  }
}
