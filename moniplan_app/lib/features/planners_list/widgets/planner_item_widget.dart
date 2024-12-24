import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PlannerItemWidget extends StatelessWidget {
  const PlannerItemWidget({
    super.key,
    required this.planner,
    this.onPressed,
  });

  final Planner planner;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final needToPay = planner.currentBudget;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(plannerBoundDateFormat).format(planner.dateStart),
                    style: context.theme.textTheme.bodyMedium,
                  ),
                  Text(
                    DateFormat(plannerBoundDateFormat).format(planner.dateEnd),
                    style: context.theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      children: [
                        _PlannerInfoItem(
                          icon: Icons.done_all,
                          value: planner.countDonePayments.toString(),
                          iconColor: Colors.green,
                        ),
                        _PlannerInfoItem(
                          icon: Icons.timelapse,
                          value: planner.countWaitingPayments.toString(),
                          iconColor: Colors.orange,
                        ),
                        _PlannerInfoItem(
                          icon: Icons.disabled_visible,
                          value: planner.countDisabledPayments.toString(),
                          iconColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  _PlannerInfoItem(
                    icon: Icons.outbond_outlined,
                    valueWidget: MoneyColoredWidget(
                      value: needToPay,
                      currency: CurrencyDataCommon.rub,
                      showPlusSign: false,
                    ),
                    iconColor: needToPay.toInt() == 0
                        ? Colors.grey
                        : needToPay > 0
                            ? Colors.green
                            : Colors.red,
                  )
                ],
              ),
              if (planner.actualInfo != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last compute: ${DateFormat(dateFormatWithTime).format(planner.actualInfo!.updatedAt)}',
                  style: context.theme.textTheme.labelLarge,
                  textAlign: TextAlign.start,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlannerInfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color iconColor;
  final Widget? valueWidget;

  const _PlannerInfoItem({
    required this.icon,
    required this.iconColor,
    this.value = '',
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          valueWidget ??
              Text(
                value,
                style: context.theme.textTheme.bodyLarge,
              )
        ],
      ),
    );
  }
}
