import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:moniplan/_widget/export.dart';
import 'package:moniplan/_widget/util/layout.dart';
import 'package:moniplan/module/operation/export.dart';
import 'package:moniplan/util/export.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final DateTime day;
  final Prediction? prediction;
  final VoidCallback? onToggleExpand;

  const CalendarHeaderWidget({
    Key? key,
    required this.day,
    this.prediction,
    this.onToggleExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandWidthLayout.builder(
      builder: (context, width) {
        final color = Theme.of(context).scaffoldBackgroundColor;
        return Material(
          elevation: 0,
          color: color,
          child: InkWell(
            onTap: () => onToggleExpand?.call(),
            child: Container(
              alignment: Alignment.centerLeft,
              width: width,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Text(
                    DateFormat("dd MMM").format(day).toUpperCase(),
                    style: Theme.of(context).textTheme.subtitle2?.apply(
                          color: color.luminance(light: Colors.black),
                        ),
                  ),
                  if (prediction != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: BudgetSummaryWidget(
                          data: prediction!,
                          currency: CommonCurrencies().rub,
                        ),
                      ),
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
