import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/bloc/budget_prediction_bloc.dart';

import 'package:moniplan/widget/day_widgets.dart';
import 'package:moniplan/widget/event_edit_page.dart';
import 'package:moniplan/widget/layout.dart';
import 'package:moniplan/util/export.dart';
import 'package:sticky_infinite_list/sticky_infinite_list.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';

class BudgetScheduleWidget extends StatelessWidget {
  final Map<DateTime, List<BudgetEvent>> eventsByDay;

  const BudgetScheduleWidget({Key? key, required this.eventsByDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().date;
    return BlocBuilder<BudgetPredictionBloc, BudgetPredictionState>(
      builder: (context, state) {
        return InfiniteList(
          posChildCount: 365,
          negChildCount: 730,
          direction: InfiniteListDirection.multi,
          builder: (BuildContext context, int index) {
            final day = now.add(Duration(days: index));

            if (eventsByDay.containsKey(day)) {
              return InfiniteListItem(
                padding: const EdgeInsets.only(top: 12),
                positionAxis: HeaderPositionAxis.mainAxis,
                headerBuilder: (context) => ExpandWidthLayout.builder(
                  builder: (context, width) {
                    final color = Theme.of(context).scaffoldBackgroundColor;
                    return Material(
                      elevation: 0,
                      color: color,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat("dd MMM").format(day).toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  ?.apply(
                                    color: color.luminance(light: Colors.black),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                contentBuilder: (context) {
                  if (state is PredictionSuccess) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DayPlanWidget(
                        date: day,
                        events: state.events[day] ?? [],
                        onPressed: (event) async {
                          BudgetEventEditPage.showEditModal(
                            context: context,
                            event: event,
                          );
                        },
                      ),
                    );
                  } else if (state is PredictionInProgress) {
                    return CircularProgressIndicator();
                  } else {
                    return Text("ERROR");
                  }
                },
              );
            } else {
              return InfiniteListItem(
                contentBuilder: (context) => SizedBox(),
              );
            }
          },
        );
      },
    );
  }
}
