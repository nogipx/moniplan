import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/module/operation/export.dart';
import 'package:moniplan/common/util/export.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final DateTime today;
  final DateTime day;
  final double? predictionValue;
  final VoidCallback? onPressed;

  const CalendarHeaderWidget({
    Key? key,
    required this.day,
    required this.today,
    this.predictionValue,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandWidthLayout.builder(
      builder: (context, width) {
        final color = Theme.of(context).scaffoldBackgroundColor;
        final accentColor = Theme.of(context).accentColor;
        return Material(
          elevation: 0,
          color: color,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              alignment: Alignment.centerLeft,
              width: width,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      DateFormat(DateFormat.MONTH_DAY, 'ru').format(day),
                      style: Theme.of(context).textTheme.subtitle1?.apply(
                            color: color.luminance(
                              dark: today == day ? accentColor : Colors.black,
                            ),
                          ),
                    ),
                  ),
                  if (predictionValue != null)
                    BudgetSummaryWidget(
                      summaryValue: predictionValue!,
                      currency: CommonCurrencies().rub,
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
