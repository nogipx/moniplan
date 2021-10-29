import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/module/operation/widget/calendar_header.dart';
import 'package:moniplan/module/operation/widget/calendar_item.dart';
import 'package:moniplan/module/operation/widget/create_operation_list_item.dart';
import 'package:moniplan/module/operation/widget/operation_list_item.dart';
import 'package:sticky_infinite_list/sticky_infinite_list.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';

class OperationsListWidget extends StatefulWidget {
  final Map<DateTime, Prediction> eventsByDay;

  const OperationsListWidget({Key? key, required this.eventsByDay})
      : super(key: key);

  @override
  _OperationsListWidgetState createState() => _OperationsListWidgetState();
}

class _OperationsListWidgetState extends State<OperationsListWidget>
    with TickerProviderStateMixin {
  late Map<DateTime, bool> _isDateExpanded;

  @override
  void initState() {
    _isDateExpanded = {};
    super.initState();
  }

  @override
  void dispose() {
    _isDateExpanded.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().date;
    return BlocBuilder<BudgetPredictionCubit, BudgetPredictionState>(
      builder: (context, state) {
        final latestDate =
            state is PredictionSuccess && state.events.keys.isNotEmpty
                ? state.events.keys.last
                : null;

        return InfiniteList(
          posChildCount: 730,
          negChildCount: 730,
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          anchor: (latestDate?.isAfter(now) ?? false) ? .2 : 0,
          direction: InfiniteListDirection.multi,
          builder: (BuildContext context, int index) {
            final day = now.subtract(Duration(days: index)).date;

            if (widget.eventsByDay.containsKey(day)) {
              return InfiniteListItem(
                positionAxis: HeaderPositionAxis.mainAxis,
                headerBuilder: (context) => CalendarHeaderWidget(
                  day: day,
                  today: now,
                  prediction:
                      state is PredictionSuccess ? state.events[day] : null,
                ),
                contentBuilder: (context) {
                  if (state is PredictionSuccess) {
                    final prediction = state.events[day];
                    if (prediction == null) {
                      return SizedBox();
                    } else {
                      return Container(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          children: [
                            if (_isDateExpanded[day] ?? true)
                              CalendarItem(prediction: prediction),
                            if (day == now)
                              CreateOperationItem(
                                onPressed: () async {
                                  await OperationWidget.showEdit(
                                    context: context,
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    }
                  } else if (state is PredictionInProgress) {
                    return CircularProgressIndicator();
                  } else {
                    return Text("ERROR");
                  }
                },
              );
            } else {
              return InfiniteListItem(
                contentBuilder: (context) => const SizedBox.shrink(),
              );
            }
          },
        );
      },
    );
  }
}
