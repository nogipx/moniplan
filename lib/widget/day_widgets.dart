import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:dartx/dartx.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/widget/layout.dart';
import 'package:moniplan/widget/operation_edit_widget.dart';
import 'package:moniplan/util/export.dart';

class GoogleDateMarker extends StatelessWidget {
  final DateTime date;
  final Color? todayColor;

  const GoogleDateMarker({
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
    final color = eventColor ?? Colors.white;
    final textColor =
        color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    final eventTotal = event.total;

    return Card(
      margin: const EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (event.title.isNotEmpty)
              Text(event.title,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .apply(color: textColor)),
            SizedBox(height: event.operations.isNotEmpty ? 12 : 0),
            OperationListWidget(
              operations: event.operations,
              textColor: color.luminance(),
            ),
            if (event.operations.isNotEmpty) Divider(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    (event.predictionValue - eventTotal).rubCurrencyString,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.caption?.copyWith(
                          color: textColor,
                        ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (eventTotal > 0 ? '+ ' : '') + eventTotal.rubCurrencyString,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption?.apply(
                          color: eventTotal == 0
                              ? Colors.grey
                              : eventTotal > 0
                                  ? Colors.green
                                  : Colors.red,
                        ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.predictionValue.rubCurrencyString,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
          height: candidate.isEmpty ? 8 : 16,
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
    return ExpandWidthLayout.builder(
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

              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actions: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: IconSlideAction(
                      icon: Icons.remove_red_eye,
                      color: Colors.grey,
                      onTap: () {},
                    ),
                  ),
                ],
                child: InkWell(
                  onTap: () => onPressed?.call(event),
                  child: LongPressDraggable<BudgetPrediction>(
                    feedback: Container(
                      width: width,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAlias,
                        child: DayEventWidget(event: event),
                      ),
                    ),
                    childWhenDragging: Container(
                      width: width,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.saturation,
                        ),
                        child: DayEventWidget(event: event),
                      ),
                    ),
                    child: DayEventWidget(event: event),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
