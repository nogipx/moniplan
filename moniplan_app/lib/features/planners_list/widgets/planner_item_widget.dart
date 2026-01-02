import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PlannerItemWidget extends StatelessWidget {
  const PlannerItemWidget({
    required this.planner,
    super.key,
    this.onPressed,
    this.onToggleCurrent,
    this.isCurrent = false,
  });

  final Planner planner;
  final VoidCallback? onPressed;
  final VoidCallback? onToggleCurrent;
  final bool isCurrent;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (planner.name.isNotEmpty) ...[
                          Text(planner.name, style: context.text.titleLarge),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat(
                                plannerBoundDateFormat,
                              ).format(planner.dateStart),
                              style: context.theme.textTheme.bodyMedium,
                            ),
                            Text(
                              DateFormat(
                                plannerBoundDateFormat,
                              ).format(planner.dateEnd),
                              style: context.theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isCurrent
                        ? 'Снять отметку текущего планнера'
                        : 'Сделать планнер текущим',
                    onPressed: onToggleCurrent,
                    icon: Icon(
                      isCurrent ? Icons.push_pin : Icons.push_pin_outlined,
                      color: isCurrent
                          ? context.color.primary
                          : context.color.outline,
                    ),
                  ),
                ],
              ),
              if (isCurrent) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: context.color.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Текущий план',
                      style: context.text.labelMedium?.copyWith(
                        color: context.color.primary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      children: [
                        if (planner.countDonePayments > 0)
                          _PlannerInfoItem(
                            icon: Icons.done_all,
                            value: planner.countDonePayments.toString(),
                            iconColor: Colors.green,
                          ),
                        if (planner.countWaitingPayments > 0)
                          _PlannerInfoItem(
                            icon: Icons.timelapse,
                            value: planner.countWaitingPayments.toString(),
                            iconColor: Colors.orange,
                          ),
                        if (planner.countDisabledPayments > 0)
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
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 4),
          valueWidget ?? Text(value, style: context.theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
