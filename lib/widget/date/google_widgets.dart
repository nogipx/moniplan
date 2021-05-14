import 'package:flutter/material.dart';
import 'package:dartx/dartx.dart';
import 'package:intl/intl.dart';

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
