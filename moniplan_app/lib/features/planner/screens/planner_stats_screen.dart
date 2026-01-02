import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/features/planner/planner_bloc/_index.dart';
import 'package:moniplan_app/features/planner/usecases/compute_actual_planner_info.dart';
import 'package:moniplan_app/features/planner/widgets/money_flow_widget.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PlannerStatsScreen extends StatelessWidget {
  const PlannerStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика планера'),
      ),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          final computed = state.maybeMap(budgetComputed: (s) => s, orElse: () => null);
          if (computed == null) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final actualInfo =
              computed.actualInfo ??
              ComputeActualPlannerInfo(
                plannerId: computed.plannerId,
                lastUpdatedBudget: computed.moneyFlow.balance,
                payments: computed.payments,
              ).run();
          final points = _buildBalancePoints(computed);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PlannerBloc>().add(const PlannerEvent.computeBudget());
              await Future.delayed(const Duration(milliseconds: 200));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _BalanceChartCard(
                  points: points,
                  initialBalance: computed.moneyFlow.initialBalance,
                ),
                const SizedBox(height: 16),
                MoneyFlowWidget(state: computed.moneyFlow),
                const SizedBox(height: 16),
                _ActualInfoGrid(info: actualInfo),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalanceChartCard extends StatelessWidget {
  const _BalanceChartCard({required this.points, required this.initialBalance});

  final List<_BalancePoint> points;
  final num initialBalance;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return Card(
        elevation: 0,
        color: context.color.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.color.outlineVariant, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.show_chart_rounded, color: context.color.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Недостаточно данных для построения графика',
                  style: context.text.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final spots = points
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(entry.key.toDouble(), entry.value.balance.toDouble()),
        )
        .toList();

    final minY = spots.map((s) => s.y).reduce(min);
    final maxY = spots.map((s) => s.y).reduce(max);
    final padding = max((maxY - minY).abs() * 0.08, 25).toDouble();
    final formatter = NumberFormat.compact();

    final delta = points.last.balance - initialBalance;
    final todayIndex = _findTodayIndex(points);
    final todayColor = context.color.tertiary;
    final yRange = (maxY - minY).abs();
    final yInterval = (yRange == 0 ? 1 : yRange / 4).toDouble();
    const xInterval = 1.0;
    final labelIndexes = _labelIndexesRange(0, points.length - 1, target: 6);

    return Card(
      elevation: 0,
      color: context.color.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.color.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, size: 18, color: context.color.primary),
                const SizedBox(width: 8),
                Text(
                  'Динамика баланса',
                  style: context.text.labelLarge?.copyWith(color: context.color.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: LineChart(
                LineChartData(
                  minY: minY - padding,
                  maxY: maxY + padding,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => context.color.surfaceContainerHighest,
                      tooltipMargin: 8,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((barSpot) {
                          final index = barSpot.x.toInt().clamp(0, points.length - 1);
                          final point = points[index];
                          return LineTooltipItem(
                            '${DateFormat('dd MMM, E', 'ru').format(point.date)}\n'
                            'Баланс: ${formatter.format(point.balance)}\n'
                            'Δ день: ${formatter.format(point.delta)}\n'
                            'Доход: ${formatter.format(point.income)} • Расход: ${formatter.format(point.outcome.abs())}',
                            (context.text.bodyMedium ?? const TextStyle()).copyWith(
                              color: context.color.onSurface,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: yInterval,
                        getTitlesWidget: (value, _) {
                          final style = (context.text.bodySmall ?? const TextStyle()).copyWith(
                            color: context.color.onSurfaceVariant,
                          );
                          return Text(formatter.format(value), style: style);
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          final index = value.round();
                          if (!labelIndexes.contains(index) ||
                              index < 0 ||
                              index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final date = points[index].date;
                          final text = DateFormat('dd.MM').format(date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              text,
                              style: context.text.bodySmall?.copyWith(
                                color: context.color.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: yInterval,
                    verticalInterval: xInterval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: context.color.outlineVariant,
                      strokeWidth: 0.6,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: context.color.outlineVariant.withValues(alpha: 0.2),
                      strokeWidth: 0.4,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: initialBalance.toDouble(),
                        color: context.color.outline,
                        strokeWidth: 0.8,
                        dashArray: [6, 6],
                        label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (_) => 'Стартовый баланс',
                          alignment: Alignment.topLeft,
                          style: context.text.bodySmall?.copyWith(
                            color: context.color.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    verticalLines: [
                      if (todayIndex != null)
                        VerticalLine(
                          x: todayIndex.toDouble(),
                          color: todayColor,
                          strokeWidth: 1,
                          dashArray: [4, 6],
                          label: VerticalLineLabel(
                            show: true,
                            labelResolver: (_) => 'Сегодня',
                            alignment: Alignment.bottomRight,
                            style: context.text.bodySmall?.copyWith(color: todayColor),
                          ),
                        ),
                    ],
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: context.color.primary,
                      gradient: LinearGradient(
                        colors: [
                          context.color.primary,
                          context.color.primary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            context.color.primary.withValues(alpha: 0.2),
                            context.color.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _BalanceChip(
                  label: 'Старт',
                  value: initialBalance,
                  icon: Icons.play_circle_fill_rounded,
                  highlight: false,
                ),
                _BalanceChip(
                  label: 'Сейчас',
                  value: points.last.balance,
                  icon: Icons.flag_circle_rounded,
                  highlight: true,
                ),
                _BalanceChip(
                  label: 'Δ',
                  value: delta,
                  icon: Icons.trending_up_rounded,
                  highlight: delta >= 0,
                ),
                _BalanceChip(
                  label: 'Мин.',
                  value: minY,
                  icon: Icons.vertical_align_bottom_rounded,
                  highlight: false,
                ),
                _BalanceChip(
                  label: 'Макс.',
                  value: maxY,
                  icon: Icons.vertical_align_top_rounded,
                  highlight: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final num value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? context.color.primary.withValues(alpha: 0.08)
            : context.color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.color.outlineVariant, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: highlight ? context.color.primary : context.color.onSurface),
          const SizedBox(width: 6),
          Text(label, style: context.text.labelMedium),
          const SizedBox(width: 6),
          MoneyColoredWidget(
            value: value,
            currency: CurrencyDataCommon.rub,
            textStyle: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: highlight ? context.color.primary : null,
            ),
            overridePositiveColor: highlight ? context.color.primary : null,
          ),
        ],
      ),
    );
  }
}

class _ActualInfoGrid extends StatelessWidget {
  const _ActualInfoGrid({required this.info});

  final PlannerActualInfo info;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.color.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.color.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stacked_bar_chart_rounded, size: 18, color: context.color.primary),
                const SizedBox(width: 8),
                Text(
                  'Статус задач',
                  style: context.text.labelLarge?.copyWith(color: context.color.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Выполнено',
                    value: info.completedCount,
                    color: context.ext<MoniplanExtraColors>()?.moneyPositive,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'В процессе',
                    value: info.waitingCount,
                    color: context.color.primary,
                    icon: Icons.hourglass_bottom_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Отключено',
                    value: info.disabledCount,
                    color: context.color.outline,
                    icon: Icons.remove_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Всего',
                    value: info.totalCount,
                    color: context.color.onSurface,
                    icon: Icons.all_inclusive_rounded,
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final num value;
  final Color? color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: context.color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.color.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color ?? context.color.onSurface),
              const SizedBox(width: 8),
              Text(label, style: context.text.labelMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color ?? context.color.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalancePoint {
  _BalancePoint({
    required this.date,
    required this.balance,
    this.delta = 0,
    this.income = 0,
    this.outcome = 0,
  });

  final DateTime date;
  final num balance;
  final num delta;
  final num income;
  final num outcome;
}

List<_BalancePoint> _buildBalancePoints(PlannerBudgetComputedState state) {
  final payments = state.payments.where((p) => p.isEnabled).toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  final points = <_BalancePoint>[];
  var balance = state.moneyFlow.initialBalance;

  final startDate = state.dateStart ?? (payments.isNotEmpty ? payments.first.date : DateTime.now());
  final endDate =
      state.dateEnd ??
      (payments.isNotEmpty ? payments.last.date : startDate.add(const Duration(days: 7)));

  final paymentsByDay = <DateTime, List<Payment>>{};
  for (final payment in payments) {
    final day = payment.date.dayBound;
    paymentsByDay.putIfAbsent(day, () => []).add(payment);
  }

  var cursor = startDate.dayBound;
  while (!cursor.isAfter(endDate.dayBound)) {
    final dayPayments = paymentsByDay[cursor] ?? const <Payment>[];
    var dayIncome = 0.0;
    var dayOutcome = 0.0;
    var dayDelta = 0.0;

    for (final payment in dayPayments) {
      final value = payment.normalizedMoney;
      dayDelta += value;
      if (payment.type == PaymentType.income) {
        dayIncome += value;
      } else if (payment.type == PaymentType.expense) {
        dayOutcome += value;
      }
    }

    balance += dayDelta;
    points.add(
      _BalancePoint(
        date: cursor,
        balance: balance,
        delta: dayDelta,
        income: dayIncome,
        outcome: dayOutcome,
      ),
    );

    cursor = cursor.add(const Duration(days: 1));
  }

  if (points.length == 1) {
    points.add(
      _BalancePoint(
        date: points.first.date.add(const Duration(days: 1)),
        balance: balance,
        delta: 0,
      ),
    );
  }

  return points;
}

Set<int> _labelIndexesRange(int start, int end, {int target = 6}) {
  final length = max(1, end - start + 1);
  if (length <= 3) {
    return {start, end};
  }
  final step = max(1, (length / target).floor());
  final indexes = <int>{start, end};
  for (var i = start + step; i < end; i += step) {
    indexes.add(i);
  }
  return indexes;
}

int? _findTodayIndex(List<_BalancePoint> points) {
  final today = DateTime.now().dayBound;
  for (var i = 0; i < points.length; i++) {
    if (points[i].date.isSameDay(today)) {
      return i;
    }
  }
  return null;
}
