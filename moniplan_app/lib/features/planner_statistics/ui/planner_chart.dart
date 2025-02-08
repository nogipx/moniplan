import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PlannerChart extends StatelessWidget {
  final Map<DateTime, num> totalBudget;
  final Map<DateTime, num> incomes;
  final Map<DateTime, num> expenses;

  const PlannerChart({
    required this.totalBudget,
    required this.incomes,
    required this.expenses,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (totalBudget.isEmpty) {
      return const Center(child: Text('Нет данных для отображения графика'));
    }

    final primaryColor = context.color.tertiary;
    final textColor = context.color.onSurface;

    // Получаем все уникальные даты
    final allDates = {...totalBudget.keys}.toList()..sort((a, b) => a.compareTo(b));

    // Создаем точки для линии общего бюджета
    final List<FlSpot> lineSpots = allDates
        .map((date) {
          final yValue = (totalBudget[date] ?? 0).toDouble();
          return yValue.isFinite ? FlSpot(date.millisecondsSinceEpoch.toDouble(), yValue) : null;
        })
        .whereType<FlSpot>()
        .toList();

    final maxY = totalBudget.values.reduce((max, value) => value > max ? value : max);
    final minY = totalBudget.values.reduce((min, value) => value < min ? value : min);
    const dotArea = 30.0;

    var lineChart = LineChart(
      transformationConfig: FlTransformationConfig(
        scaleAxis: FlScaleAxis.horizontal,
      ),
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            isStepLineChart: true,
            spots: lineSpots,
            isCurved: false,
            color: primaryColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
            ),
            aboveBarData: BarAreaData(
              show: true,
              applyCutOffY: true,
              color: context.extra.moneyNegative.withAlpha(50),
            ),
            belowBarData: BarAreaData(
              show: true,
              applyCutOffY: true,
              color: context.extra.moneyPositive.withAlpha(50),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(),
          rightTitles: AxisTitles(),
          bottomTitles: AxisTitles(),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: dotArea,
              getTitlesWidget: (value, meta) {
                if (!value.isFinite) return const SizedBox.shrink();
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  '${date.month}/${date.year}',
                  style: TextStyle(color: textColor),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
        ),
        borderData: FlBorderData(show: false),
        minY: minY.toDouble(),
        maxY: maxY.toDouble(),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            scrollDirection: Axis.horizontal,
            // child: const SizedBox.shrink(),
            child: SizedBox(
              width: totalBudget.length * dotArea,
              child: lineChart,
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
