import 'package:flutter/material.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PlannerItemWidget extends StatelessWidget {
  const PlannerItemWidget({
    super.key,
    required this.planner,
    this.onPressed,
  });

  final PaymentPlanner planner;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final needToPay = planner.needToPay * -1;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(plannerBoundDateFormat).format(planner.dateStart),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    DateFormat(plannerBoundDateFormat).format(planner.dateEnd),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                      currency: AppCurrencies.ru,
                      showPlusSign: false,
                    ),
                    iconColor: needToPay.toInt() == 0
                        ? Colors.grey
                        : needToPay > 0
                            ? Colors.green
                            : Colors.red,
                  )
                ],
              )
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
    super.key,
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
          const SizedBox(width: 8),
          valueWidget ??
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              )
        ],
      ),
    );
  }
}
