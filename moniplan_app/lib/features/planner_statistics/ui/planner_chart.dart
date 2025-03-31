import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

// Модель точки графика
class ChartPoint {
  final double y;
  final String? label;

  ChartPoint({required this.y, this.label});
}

// Модель индикатора даты
class DateIndicator {
  final DateTime date;
  final String label;
  final Color color;

  DateIndicator({required this.date, required this.label, required this.color});
}

class PlannerChart extends StatelessWidget {
  final Map<DateTime, List<ChartPoint>> points;
  final DateTime minDate;
  final DateTime maxDate;
  final List<DateIndicator>? dateIndicators;

  const PlannerChart({
    Key? key,
    required this.points,
    required this.minDate,
    required this.maxDate,
    this.dateIndicators,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final positiveColor = context.ext<MoniplanExtraColors>()?.moneyPositive ?? Colors.green;
    final negativeColor = context.ext<MoniplanExtraColors>()?.moneyNegative ?? Colors.red;

    final allPoints =
        points.entries
            .expand(
              (entry) =>
                  entry.value.map((e) => FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), e.y)),
            )
            .toList();

    final spotsByDate = <DateTime, List<FlSpot>>{};
    for (final entry in points.entries) {
      spotsByDate[entry.key] =
          entry.value.map((e) => FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), e.y)).toList();
    }

    final todaySpot =
        spotsByDate.entries
            .where(
              (e) => e.key.year == now.year && e.key.month == now.month && e.key.day == now.day,
            )
            .map((e) => e.value)
            .firstOrNull;

    final budgetLineSpots =
        spotsByDate.entries
            .where((entry) => entry.value.length > 1)
            .map((entry) => entry.value.last)
            .toList();

    final incomeLineSpots =
        spotsByDate.entries
            .where((entry) => entry.value.length > 1)
            .map((entry) => entry.value.first)
            .toList();

    final lineColors = [positiveColor, negativeColor, Colors.blueGrey[900] ?? Colors.blueGrey];

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Динамика бюджета',
                            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateFormat('d MMMM', 'ru').format(minDate)} - ${DateFormat('d MMMM', 'ru').format(maxDate)}',
                            style: context.text.bodySmall?.copyWith(
                              color: context.text.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildLegend(
                      context,
                      positiveColor: positiveColor,
                      negativeColor: negativeColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor:
                            (touchedSpot) =>
                                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());

                            String title = '';
                            Color? color;

                            if (spot == spots.last) {
                              title = 'Баланс';
                              color = Colors.blueGrey[800];
                            } else if (spot == spots.first) {
                              title = 'Доход';
                              color = positiveColor;
                            } else {
                              title = 'Расход';
                              color = negativeColor;
                            }

                            return LineTooltipItem(
                              '${DateFormat('d MMM', 'ru').format(date)}\n$title: ${spot.y.round()} ₽',
                              TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1000,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                          strokeWidth: 0.5,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 86400000 * 5, // примерно 5 дней
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

                            // Показываем только первый день месяца и сегодняшний день
                            if (date.day == 1 || date.isAtSameDay(now)) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  date.day == 1 ? DateFormat('MMM', 'ru').format(date) : 'Сегодня',
                                  style: context.text.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color:
                                        date.isAtSameDay(now)
                                            ? Theme.of(context).colorScheme.primary
                                            : null,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5000,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt() / 1000}K',
                              style: context.text.bodySmall?.copyWith(fontSize: 10),
                              textAlign: TextAlign.left,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: minDate.millisecondsSinceEpoch.toDouble(),
                    maxX: maxDate.millisecondsSinceEpoch.toDouble(),
                    minY: 0,
                    maxY:
                        allPoints.isEmpty
                            ? 10000
                            : allPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1,
                    lineBarsData: [
                      // Линия дохода
                      LineChartBarData(
                        spots: incomeLineSpots,
                        isCurved: true,
                        gradient: LinearGradient(colors: [lineColors[0], lineColors[0]]),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              lineColors[0].withOpacity(0.2),
                              lineColors[0].withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Линия расхода
                      LineChartBarData(
                        spots: budgetLineSpots,
                        isCurved: true,
                        gradient: LinearGradient(colors: [lineColors[2], lineColors[2]]),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              lineColors[2].withOpacity(0.2),
                              lineColors[2].withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    extraLinesData: ExtraLinesData(
                      verticalLines: [
                        // Вертикальная линия для текущего дня
                        VerticalLine(
                          x: now.millisecondsSinceEpoch.toDouble(),
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(
    BuildContext context, {
    required Color positiveColor,
    required Color negativeColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(color: positiveColor, label: 'Доход'),
        const SizedBox(width: 12),
        _LegendItem(color: Colors.blueGrey[900] ?? Colors.blueGrey, label: 'Баланс'),
        const SizedBox(width: 12),
        _LegendItem(color: Theme.of(context).colorScheme.primary, label: 'Сегодня', isDashed: true),
      ],
    );
  }
}

extension DateTimeExtension on DateTime {
  bool isAtSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendItem({required this.color, required this.label, this.isDashed = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isDashed)
          Container(
            width: 12,
            height: 2,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: color, width: 2, style: BorderStyle.solid)),
            ),
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 4),
        Text(label, style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _InfoChip({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color ?? Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: context.text.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
