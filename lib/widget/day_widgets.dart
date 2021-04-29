import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dartx/dartx.dart';
import 'package:money2/money2.dart';
import 'package:planimon/bloc/budget_prediction_bloc.dart';
import 'package:planimon/sdk/domain.dart';
import 'package:planimon/widget/layout.dart';
import 'package:planimon/widget/operation_edit_widget.dart';
import 'package:planimon/widget/operation_widgets.dart';
import 'package:planimon/util/export.dart';

class DayMarkerWidget extends StatelessWidget {
  final DateTime date;
  final Color? todayColor;

  const DayMarkerWidget({
    Key? key,
    required this.date,
    this.todayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isToday = date.isAtSameDayAs(DateTime.now());
    final color = isToday
        ? todayColor ?? Theme.of(context).accentColor
        : Colors.transparent;

    return Container(
      width: 30,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            DateFormat("MMM").format(date).toUpperCase(),
            style: Theme.of(context).textTheme.caption?.copyWith(
                  color: isToday ? color : null,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (isToday)
            CircleAvatar(
              backgroundColor: color,
              radius: 16,
              child: _buildDay(context, color, isToday),
            ),
          if (!isToday) _buildDay(context, color, isToday)
        ],
      ),
    );
  }

  Widget _buildDay(BuildContext context, Color color, bool isToday) {
    return Text(
      date.day.toString(),
      style: Theme.of(context).textTheme.subtitle2?.apply(
          color: color.computeLuminance() > 0.5 || !isToday
              ? Colors.black87
              : Colors.white),
    );
  }
}

class DayEventWidget extends StatelessWidget {
  final BudgetPrediction event;
  final Color? eventColor;

  const DayEventWidget({
    Key? key,
    required this.event,
    this.eventColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = eventColor ?? Theme.of(context).accentColor;
    final textColor =
        color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    final eventTotal = event.total;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Money.from(
              event.predictionValue,
              event.predictionValue.rubCurrency,
            ).toString(),
            style:
                Theme.of(context).textTheme.subtitle2?.apply(color: textColor),
          ),
          SizedBox(height: event.operations.isNotEmpty ? 8 : 0),
          OperationListWidget(
            operations: event.operations,
            textColor: color.luminance(),
          ),
          SizedBox(height: event.operations.isNotEmpty ? 2 : 0),
          Text(
            "= ${Money.from(eventTotal, eventTotal.rubCurrency)}",
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.subtitle2?.apply(
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }
}

class DayPlanWidget extends StatelessWidget {
  final DateTime date;
  final List<BudgetPrediction> events;
  final void Function(BudgetPrediction)? onPressed;

  const DayPlanWidget({
    Key? key,
    required this.date,
    required this.events,
    this.onPressed,
  }) : super(key: key);

  Widget _buildDragTarget(int index) {
    return DragTarget<BudgetPrediction>(
      builder: (context, candidate, reject) {
        return SizedBox(
          height: candidate.isEmpty ? 8 : 24,
          child: Offstage(
            offstage: candidate.isEmpty,
            child: Divider(
              thickness: 2,
              color: Colors.blue,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ExpandWidthLayout.builder(
        builder: (context, width) {
          return Container(
            width: width,
            child: ListView.separated(
              itemCount: events.length + 2,
              primary: false,
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                if (index != 0 && index != events.length) {
                  return _buildDragTarget(index);
                } else {
                  return SizedBox();
                }
              },
              itemBuilder: (context, index) {
                if (index == 0 || index == events.length + 1) {
                  return _buildDragTarget(index);
                }
                final event = events[index - 1];
                final eventWidget = DayEventWidget(event: event);
                const padding = EdgeInsets.only(left: 12);
                return InkWell(
                  onTap: () => onPressed?.call(event),
                  child: LongPressDraggable<BudgetPrediction>(
                    feedback: Container(
                      width: width,
                      padding: padding,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAlias,
                        child: eventWidget,
                      ),
                    ),
                    childWhenDragging: Container(
                      width: width,
                      padding: padding,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.saturation,
                        ),
                        child: eventWidget,
                      ),
                    ),
                    child: Padding(
                      padding: padding,
                      child: eventWidget,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
