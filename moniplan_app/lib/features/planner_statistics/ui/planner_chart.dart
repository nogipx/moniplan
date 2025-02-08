import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    // Получаем все уникальные даты
    final allDates = {...totalBudget.keys, ...incomes.keys, ...expenses.keys}.toList()..sort();

    // Создаем точки для линии общего бюджета
    final List<FlSpot> lineSpots = allDates
        .map((date) => FlSpot(
              date.millisecondsSinceEpoch.toDouble(),
              totalBudget[date] ?? 0,
            ))
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
            toY: (expenses[date] ?? 0).abs() * -1, // Отрицательные значения для расходов
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              AspectRatio(
                aspectRatio: 1.7,
                child: Stack(
                  children: [
                    BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY * 1.2,
                        minY: maxY * -0.5,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final date = DateTime.fromMillisecondsSinceEpoch(group.x);
                              final value = rod.toY.abs();
                              final type = rodIndex == 0 ? 'Доход' : 'Расход';
                              return BarTooltipItem(
                                '$type\n${date.day}.${date.month}\n${value.toStringAsFixed(2)}',
                                TextStyle(color: textColor),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${date.day}.${date.month}',
                                    style: TextStyle(fontSize: 10, color: textColor),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(fontSize: 10, color: textColor),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        barGroups: barGroups,
                      ),
                    ),
                    LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineSpots,
                            isCurved: true,
                            color: primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
