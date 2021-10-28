import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/module/operation/widget/calendar_header.dart';
import 'package:moniplan/module/operation/widget/calendar_item.dart';
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
          physics: BouncingScrollPhysics(),
          direction: InfiniteListDirection.multi,
          builder: (BuildContext context, int index) {
            final day = now.add(Duration(days: index)).date;

            if (widget.eventsByDay.containsKey(day)) {
              return InfiniteListItem(
                padding: EdgeInsets.only(
                  bottom: latestDate != null && day == latestDate ? 80 : 0,
                ),
                positionAxis: HeaderPositionAxis.mainAxis,
                headerBuilder: (context) => CalendarHeaderWidget(
                  day: day,
                  today: now,
                  prediction:
                      state is PredictionSuccess ? state.events[day] : null,
                  onToggleExpand: () {
                    setState(() {
                      final currentToggle = _isDateExpanded[day];
                      _isDateExpanded[day] = !(currentToggle ?? false);
                    });
                  },
                ),
                contentBuilder: (context) {
                  if (state is PredictionSuccess) {
                    final prediction = state.events[day];
                    if (prediction == null) {
                      return SizedBox();
                    } else {
                      return AnimatedSize(
                        vsync: this,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.fastLinearToSlowEaseIn,
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: (_isDateExpanded[day] ?? true)
                              ? CalendarItem(
                                  prediction: prediction,
                                )
                              : null,
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
                contentBuilder: (context) => SizedBox.shrink(),
              );
            }
          },
        );
      },
    );
  }
}
