import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';
import 'package:moniplan/bloc/budget_prediction_bloc.dart';
import 'package:moniplan/widget/budget/budget_summary.dart';
import 'package:moniplan/widget/budget/operation_widget.dart';

import 'package:moniplan/widget/util/layout.dart';
import 'package:moniplan/util/export.dart';
import 'package:sticky_infinite_list/sticky_infinite_list.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';

class BudgetScheduleWidget extends StatelessWidget {
  final Map<DateTime, BudgetPrediction> eventsByDay;

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
                padding: const EdgeInsets.only(top: 20),
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
                    final operations = state.events[day]!.operations;

                    return Card(
                      margin: const EdgeInsets.all(0),
                      elevation: 1,
                      shape: RoundedRectangleBorder(),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            // separatorBuilder: (_, __) => SizedBox(height: 8),
                            itemCount: operations.length,
                            itemBuilder: (context, index) {
                              return OperationWidget(
                                data: operations[index],
                                onPressed: () async {
                                  await OperationWidget.showEdit(
                                    context: context,
                                    initialData: operations[index],
                                  ).then((value) {
                                    if (value != null) {
                                      context
                                          .read<OperationService>()
                                          .save(value);
                                      context
                                          .read<BudgetPredictionBloc>()
                                          .compute();
                                    }
                                  });
                                },
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(height: 4),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: BudgetSummaryWidget(
                              data: state.events[day]!,
                              currency: CommonCurrencies().rub,
                            ),
                          )
                        ],
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
