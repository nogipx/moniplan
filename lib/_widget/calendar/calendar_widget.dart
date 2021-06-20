import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/_widget/calendar/calendar_header.dart';
import 'package:moniplan/_widget/calendar/calendar_item.dart';
import 'package:moniplan/bloc/budget_prediction_bloc.dart';
import 'package:sticky_infinite_list/sticky_infinite_list.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:dartx/dartx.dart';

class OperationsListWidget extends StatelessWidget {
  final Map<DateTime, Prediction> eventsByDay;

  const OperationsListWidget({Key? key, required this.eventsByDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().date;
    return BlocBuilder<BudgetPredictionBloc, BudgetPredictionState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: InfiniteList(
            posChildCount: 365,
            negChildCount: 730,
            direction: InfiniteListDirection.multi,
            builder: (BuildContext context, int index) {
              final day = now.add(Duration(days: index));

              if (eventsByDay.containsKey(day)) {
                return InfiniteListItem(
                  padding: const EdgeInsets.only(top: 32),
                  positionAxis: HeaderPositionAxis.mainAxis,
                  headerBuilder: (context) => CalendarHeaderWidget(
                    day: day,
                    prediction:
                        state is PredictionSuccess ? state.events[day] : null,
                  ),
                  contentBuilder: (context) {
                    if (state is PredictionSuccess) {
                      final prediction = state.events[day];
                      if (prediction == null) {
                        return SizedBox();
                      } else {
                        return CalendarItem(prediction: prediction);
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
                  contentBuilder: (context) => SizedBox(),
                );
              }
            },
          ),
        );
      },
    );
  }
}
