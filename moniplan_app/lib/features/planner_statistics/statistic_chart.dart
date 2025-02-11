// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// import 'package:flutter/material.dart';
// import 'package:moniplan/features/_common/_index.dart';
// import 'package:moniplan_core/moniplan_core.dart';
// import 'package:moniplan_uikit/moniplan_uikit.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
//
// class StatisticChart extends StatefulWidget {
//   final Map<Payment, num> budget;
//
//   const StatisticChart({
//     super.key,
//     required this.budget,
//   });
//
//   @override
//   State<StatisticChart> createState() => _StatisticChartState();
// }
//
// class _StatisticChartState extends State<StatisticChart> {
//   final TrackballBehavior _trackballBehavior = TrackballBehavior(
//     enable: true,
//     activationMode: ActivationMode.longPress,
//     builder: (context, data) {
//       if (data.series != null && data.seriesIndex != null && data.pointIndex != null) {
//         final MapEntry<Payment, num> item = data.series!.dataSource[data.pointIndex!];
//
//         return Material(
//           borderRadius: const BorderRadius.all(Radius.circular(8)),
//           clipBehavior: Clip.hardEdge,
//           // borderOnForeground: true,
//           child: data.seriesIndex == 0
//               ? Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.all(Radius.circular(8)),
//                     color: data.seriesIndex == 0 ? context.color.surface : context.color.surfaceDim,
//                     border: Border.all(
//                       width: 2,
//                       color: item.key.normalizedMoney == 0
//                           ? context.color.onSurface
//                           : item.key.normalizedMoney > 0
//                               ? context.extra.moneyPositive
//                               : context.extra.moneyNegative,
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(DateFormat('d MMMM', 'ru').format(item.key.date)),
//                       Text(item.key.details.name),
//                       MoneyColoredWidget(
//                         value: item.key.details.normalizedMoney,
//                         currency: item.key.details.currency,
//                       ),
//                     ],
//                   ),
//                 )
//               : const SizedBox(),
//         );
//       }
//
//       return const SizedBox();
//     },
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (context) {
//         if (widget.budget.isEmpty) {
//           return const Center(
//             child: Text('No data...'),
//           );
//         }
//
//         try {
//           return SfCartesianChart(
//             zoomPanBehavior: ZoomPanBehavior(
//               enablePanning: true,
//               enablePinching: true,
//               zoomMode: ZoomMode.x,
//             ),
//             primaryXAxis: DateTimeAxis(
//               rangePadding: ChartRangePadding.round,
//               intervalType: DateTimeIntervalType.auto,
//               dateFormat: DateFormat('dd.MM'),
//               majorGridLines: const MajorGridLines(width: 0),
//               majorTickLines: const MajorTickLines(width: 0),
//             ),
//             primaryYAxis: const NumericAxis(
//               interactiveTooltip: InteractiveTooltip(
//                 enable: true,
//               ),
//             ),
//             trackballBehavior: _trackballBehavior,
//             series: [
//               LineSeries<MapEntry<Payment, num>, DateTime>(
//                 name: 'Бюджет',
//                 color: context.color.surfaceTint,
//                 dataSource: widget.budget.entries.where((e) => e.key.isEnabled).toList(),
//                 xValueMapper: (MapEntry<Payment, num> data, _) => data.key.date,
//                 yValueMapper: (MapEntry<Payment, num> data, _) => data.value,
//               ),
//               ColumnSeries<MapEntry<Payment, num>, DateTime>(
//                 width: 1,
//                 name: 'Расход',
//                 color: context.extra.moneyNegative,
//                 dataSource: widget.budget.entries
//                     .where((e) => e.key.type.modifier < 0 && e.key.isEnabled)
//                     .toList(),
//                 xValueMapper: (MapEntry<Payment, num> data, _) => data.key.date,
//                 yValueMapper: (MapEntry<Payment, num> data, _) => data.key.normalizedMoney,
//               ),
//               ColumnSeries<MapEntry<Payment, num>, DateTime>(
//                 width: 1,
//                 name: 'Доход',
//                 color: context.extra.moneyPositive,
//                 dataSource: widget.budget.entries
//                     .where((e) => e.key.type.modifier > 0 && e.key.isEnabled)
//                     .toList(),
//                 xValueMapper: (MapEntry<Payment, num> data, _) => data.key.date,
//                 yValueMapper: (MapEntry<Payment, num> data, _) => data.key.normalizedMoney,
//               ),
//             ],
//           );
//         } on Object catch (_) {
//           return Center(
//             child: Text(
//               MoniplanKeys.i.stats.error.loading,
//             ),
//           );
//         }
//       },
//     );
//   }
// }
