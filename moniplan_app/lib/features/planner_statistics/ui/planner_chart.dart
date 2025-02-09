import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PlannerChart extends StatefulWidget {
  final BudgetStatisticsTotal totalBudget;
  final Map<DateTime, num> incomes;
  final Map<DateTime, num> expenses;

  const PlannerChart({
    required this.totalBudget,
    required this.incomes,
    required this.expenses,
    super.key,
  });

  @override
  State<PlannerChart> createState() => _PlannerChartState();
}

class _PlannerChartState extends State<PlannerChart> {
  // Определяем первую дату для каждого нового месяца
  List<FlSpot> allDoneDatesSpots = [];
  List<FlSpot> remainingDatesSpots = [];
  double maxY = 0;
  double minY = 0;

  @override
  void initState() {
    super.initState();
    _initializeChartData();
  }

  void _initializeChartData() {
    if (widget.totalBudget.isEmpty) return;

    final allDates = {...widget.totalBudget.keys}.toList()..sort((a, b) => a.compareTo(b));
    final List<DateTime> allDoneDates = [];
    final List<DateTime> remainingDates = [];
    bool foundFirstFalse = false;

    for (var date in allDates) {
      final budgetData = widget.totalBudget[date];
      if (!foundFirstFalse && (budgetData?.allCompleted ?? false)) {
        allDoneDates.add(date);
      } else {
        foundFirstFalse = true;
        remainingDates.add(date);
      }
    }

    // Создаем точки для линии выполненных дат
    allDoneDatesSpots = allDoneDates
        .map((date) {
          final budgetData = widget.totalBudget[date];
          final yValue = (budgetData?.totalBudget ?? 0).toDouble();
          return yValue.isFinite ? FlSpot(date.dayBound.millisecondsSinceEpoch.toDouble(), yValue) : null;
        })
        .whereType<FlSpot>()
        .toList();

    // Создаем точки для линии оставшихся дат
    remainingDatesSpots = remainingDates
        .map((date) {
          final budgetData = widget.totalBudget[date];
          final yValue = (budgetData?.totalBudget ?? 0).toDouble();
          return yValue.isFinite ? FlSpot(date.dayBound.millisecondsSinceEpoch.toDouble(), yValue) : null;
        })
        .whereType<FlSpot>()
        .toList();

    maxY = widget.totalBudget.values
        .reduce((max, value) => value.totalBudget > max.totalBudget ? value : max)
        .totalBudget
        .toDouble();
    minY = widget.totalBudget.values
        .reduce((min, value) => value.totalBudget < min.totalBudget ? value : min)
        .totalBudget
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalBudget.isEmpty) {
      return const Center(child: Text('Нет данных для отображения графика'));
    }

    final doneColor = Colors.green;
    final remainingColor = Colors.yellow;
    final deficitColor = Colors.red;

    final moneySideTitles = SideTitles(
      showTitles: true,
      reservedSize: 50,
      minIncluded: false,
      maxIncluded: true,
      getTitlesWidget: (value, meta) {
        if (!value.isFinite) return const SizedBox.shrink();
        final amount = value.toInt();
        // Отображаем сумму с шагом 50К, 100К, 200К, 500К и максимум
        if ((amount >= 50000 && amount < 100000) ||
            (amount >= 100000 && amount < 200000) ||
            (amount >= 200000 && amount < 500000) ||
            (amount >= 500000 && amount < maxY.toInt()) ||
            amount == maxY.toInt()) {
          return Text(
            '${amount ~/ 1000}K',
            style: TextStyle(color: context.color.onSurface),
            textAlign: TextAlign.center,
          );
        }
        return const SizedBox.shrink(); // Не отображаем метку, если она не соответствует шагу
      },
    );

    var lineChart = LineChart(
      transformationConfig: FlTransformationConfig(
        trackpadScrollCausesScale: true,
      ),
      LineChartData(
        lineBarsData: [
          // Линия общего бюджета
          LineChartBarData(
            isStepLineChart: true,
            spots: allDoneDatesSpots,
            isCurved: false,
            color: doneColor,
            barWidth: 1,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            aboveBarData: BarAreaData(
              show: true,
              applyCutOffY: true,
              color: deficitColor.withAlpha(50),
            ),
            belowBarData: BarAreaData(
              show: true,
              applyCutOffY: true,
              color: doneColor.withAlpha(50),
            ),
          ),
          LineChartBarData(
            isStepLineChart: true,
            spots: remainingDatesSpots,
            isCurved: false,
            color: remainingColor,
            barWidth: 1,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            aboveBarData: BarAreaData(
              show: true,
              applyCutOffY: true,
              color: deficitColor.withAlpha(50),
            ),
            belowBarData: BarAreaData(
              show: true,
              applyCutOffY: true,
              color: remainingColor.withAlpha(50),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            maxContentWidth: 200,
            fitInsideVertically: true,
            showOnTopOfTheChartBoxArea: true,
            tooltipMargin: -50,
            tooltipPadding: EdgeInsets.all(4),
            getTooltipColor: (spot) {
              return context.color.secondaryContainer;
            },
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((spot) {
                final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                final value = spot.y;
                final moneyText = (value > 0 ? '+ ' : '-') + value.currency(CurrencyDataCommon.rub);
                return LineTooltipItem(
                  '',
                  context.text.bodyMedium!.copyWith(
                    color: context.color.onSecondaryContainer,
                  ),
                  textAlign: TextAlign.center,
                  children: [
                    TextSpan(
                      text: '${date.day}.${date.month}.${date.year}\n',
                    ),
                    TextSpan(
                      text: moneyText,
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(),
          bottomTitles: AxisTitles(),
          leftTitles: AxisTitles(sideTitles: moneySideTitles),
          rightTitles: AxisTitles(sideTitles: moneySideTitles),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          verticalInterval: 86400000,
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY + maxY * 0.1,
      ),
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: doneColor, label: 'Выполненные'),
              const SizedBox(width: 16),
              _LegendItem(color: remainingColor, label: 'Запланированные'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 24,
              ),
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 3,
                child: lineChart,
              ),
            ),
          ),
        ],
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
