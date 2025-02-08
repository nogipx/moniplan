import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PlannerChart extends StatelessWidget {
  final Map<DateTime, double> totalBudget;
  final Map<DateTime, double> incomes;
  final Map<DateTime, double> expenses;

  const PlannerChart({
    Key? key,
    required this.totalBudget,
    required this.incomes,
    required this.expenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalBudget.isEmpty) {
      return const Center(child: Text('Нет данных для отображения графика'));
    }

    final primaryColor = context.color.tertiary;
    final textColor = context.color.onSurface;

    // Получаем все уникальные даты
    final allDates = {...incomes.keys, ...expenses.keys}.toList()..sort();

    // Создаем точки для линии общего бюджета
    final List<FlSpot> lineSpots = allDates
        .map((date) {
          final yValue = totalBudget[date] ?? 0;
          return yValue.isFinite ? FlSpot(date.millisecondsSinceEpoch.toDouble(), yValue) : null;
        })
        .whereType<FlSpot>()
        .toList();

    // Создаем группы столбцов для доходов и расходов
    final List<BarChartGroupData> barGroups = allDates.map((date) {
      return BarChartGroupData(
        x: date.millisecondsSinceEpoch.toInt(),
        barRods: [
          BarChartRodData(
            toY: incomes[date] ?? 0,
            color: Colors.green.withOpacity(0.7),
            width: 8,
          ),
          BarChartRodData(
            toY: (expenses[date] ?? 0).abs() * -1,
            color: Colors.red.withOpacity(0.7),
            width: 8,
          ),
        ],
      );
    }).toList();

    // Находим максимальные значения для масштабирования
    final maxY = [
      ...incomes.values,
      ...expenses.values.map((e) => e.abs()),
      ...totalBudget.values,
    ].reduce((max, value) => value > max ? value : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Статистика бюджета', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: Colors.green, label: 'Доходы'),
            const SizedBox(width: 16),
            _LegendItem(color: Colors.red, label: 'Расходы'),
            const SizedBox(width: 16),
            _LegendItem(color: primaryColor, label: 'Общий баланс'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: lineSpots,
                  isCurved: false,
                  color: primaryColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (!value.isFinite) return const SizedBox.shrink();
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Text(
                        '${date.day}/${date.month}',
                        style: TextStyle(color: textColor),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              // minY: 0,
              // maxY: maxY,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
