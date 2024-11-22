import 'package:flutter/material.dart';
import 'package:moniplan/theme/contour_animation/_index.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

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

    return ContourAnimationWidget(
      edgeOffsets: const EdgeInsets.all(4),
      colorGenerator: (p) => generateRainbowColor(p, offset: gaussianFunction(p) / 2),
      visibleFractionGenerator: (p) {
        return (sinusoidalFunction(p) / 8) + p / 100;
      },
      cornerRadius: 12,
      visibleFraction: 1,
      duration: const Duration(milliseconds: 6000),
      child: Card(
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
                ),
                if (planner.actualInfo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Last compute: ${DateFormat(dateFormatWithTime).format(planner.actualInfo!.updatedAt)}',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.start,
                  ),
                ],
              ],
            ),
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
                style: Theme.of(context).textTheme.bodyLarge,
              )
        ],
      ),
    );
  }
}
