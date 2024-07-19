import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticChart extends StatefulWidget {
  final Map<Payment, num> budget;

  const StatisticChart({
    super.key,
    required this.budget,
  });

  @override
  State<StatisticChart> createState() => _StatisticChartState();
}

class _StatisticChartState extends State<StatisticChart> {
  final TrackballBehavior _trackballBehavior = TrackballBehavior(
    enable: true,
    activationMode: ActivationMode.longPress,
    builder: (context, data) {
      if (data.series != null && data.seriesIndex != null && data.pointIndex != null) {
        final MapEntry<Payment, num> item = data.series!.dataSource[data.pointIndex!];

        return Material(
          elevation: 4,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          clipBehavior: Clip.hardEdge,
          borderOnForeground: true,
          child: data.seriesIndex == 0
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: data.seriesIndex == 0 ? Colors.white : Colors.black12,
                    border: Border.all(
                      width: 3,
                      color: item.key.normalizedMoney == 0
                          ? Colors.grey.shade200
                          : item.key.normalizedMoney > 0
                              ? Colors.green.shade300
                              : Colors.red.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(DateFormat('d MMMM', 'ru').format(item.key.date)),
                      Text(item.key.details.name),
                      MoneyColoredWidget(
                        value: item.key.details.normalizedMoney,
                        currency: item.key.details.currency,
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        );
      }

      return const SizedBox();
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(
        builder: (context) {
          if (widget.budget.isEmpty) {
            return const Center(
              child: Text('No data...'),
            );
          }

          try {
            return SfCartesianChart(
              zoomPanBehavior: ZoomPanBehavior(
                enablePanning: true,
                enablePinching: true,
                zoomMode: ZoomMode.x,
              ),
              primaryXAxis: DateTimeAxis(
                interval: 1,
                intervalType: DateTimeIntervalType.days,
                dateFormat: DateFormat('d MMM', 'ru'),
                majorGridLines: const MajorGridLines(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
              ),
              primaryYAxis: const NumericAxis(
                interactiveTooltip: InteractiveTooltip(
                  enable: true,
                ),
              ),
              trackballBehavior: _trackballBehavior,
              series: [
                LineSeries<MapEntry<Payment, num>, DateTime>(
                  name: 'Бюджет',
                  color: Colors.blue.shade900,
                  dataSource: widget.budget.entries.where((e) => e.key.isEnabled).toList(),
                  xValueMapper: (MapEntry<Payment, num> data, _) => data.key.date,
                  yValueMapper: (MapEntry<Payment, num> data, _) => data.value,
                ),
                ColumnSeries<MapEntry<Payment, num>, DateTime>(
                  width: 1,
                  name: 'Расход',
                  color: Colors.red.shade100,
                  dataSource: widget.budget.entries
                      .where((e) => e.key.type.modifier < 0 && e.key.isEnabled)
                      .toList(),
                  xValueMapper: (MapEntry<Payment, num> data, _) => data.key.date,
                  yValueMapper: (MapEntry<Payment, num> data, _) => data.key.normalizedMoney,
                ),
                ColumnSeries<MapEntry<Payment, num>, DateTime>(
                  width: 1,
                  name: 'Доход',
                  color: Colors.green.shade100,
                  dataSource: widget.budget.entries
                      .where((e) => e.key.type.modifier > 0 && e.key.isEnabled)
                      .toList(),
                  xValueMapper: (MapEntry<Payment, num> data, _) => data.key.date,
                  yValueMapper: (MapEntry<Payment, num> data, _) => data.key.normalizedMoney,
                ),
                // LineSeries<MapEntry<Payment, double>, String>(
                //   color: Colors.red,
                //   dataSource: budget.entries.toList(),
                //   xValueMapper: (MapEntry<Payment, double> data, _) =>
                //       DateFormat('d.M').format(data.key.date),
                //   yValueMapper: (MapEntry<Payment, double> data, _) => data.value,
                // ),
              ],
            );
          } on RangeError {}
          return const SizedBox();
        },
      ),
    );
  }
}
