import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/features/planner/planner_bloc/_index.dart';
import 'package:moniplan_app/features/planner/usecases/analyze_planner_risk_usecase.dart';
import 'package:moniplan_app/features/planner/usecases/build_balance_series_usecase.dart';
import 'package:moniplan_app/features/planner/usecases/compute_actual_planner_info.dart';
import 'package:moniplan_app/features/planner/usecases/split_periods_by_correction_usecase.dart';
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
          final points = BuildBalanceSeriesUseCase(
            payments: computed.payments,
            initialBalance: computed.moneyFlow.initialBalance,
            dateStart: computed.dateStart,
            dateEnd: computed.dateEnd,
          ).call();

          final risk = AnalyzePlannerRiskUseCase(
            series: points,
            payments: computed.payments,
            today: DateTime.now(),
          ).call();

          final periods = SplitPeriodsByCorrectionUseCase(
            series: points,
            payments: computed.payments,
          ).call();

          // График показывает только последний период — после последней
          // коррекции: более ранние данные уже сверены и не влияют на прогноз.
          final lastPeriod = periods.isNotEmpty ? periods.last : null;
          final chartPoints = lastPeriod != null
              ? points
                  .where((p) =>
                      !p.date.dayBound.isBefore(lastPeriod.start.dayBound))
                  .toList()
              : points;
          final chartInitialBalance =
              lastPeriod?.startBalance ?? computed.moneyFlow.initialBalance;
          final chartSubtitle =
              (lastPeriod != null && lastPeriod.startedByCorrection)
                  ? 'с коррекции ${DateFormat('d MMM', 'ru').format(lastPeriod.start)}'
                  : null;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PlannerBloc>().add(const PlannerEvent.computeBudget());
              await Future.delayed(const Duration(milliseconds: 200));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (risk != null) ...[
                  _RiskCard(risk: risk),
                  const SizedBox(height: 16),
                ],
                _BalanceChartCard(
                  points: chartPoints,
                  initialBalance: chartInitialBalance,
                  subtitle: chartSubtitle,
                ),
                const SizedBox(height: 16),
                if (periods.length > 1) ...[
                  _PeriodsCard(periods: periods),
                  const SizedBox(height: 16),
                ],
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
  const _BalanceChartCard({
    required this.points,
    required this.initialBalance,
    this.subtitle,
  });

  final List<BalancePoint> points;
  final num initialBalance;
  final String? subtitle;

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
                if (subtitle != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle!,
                      textAlign: TextAlign.right,
                      style: context.text.bodySmall?.copyWith(
                        color: context.color.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
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
                      if (minY < 0)
                        HorizontalLine(
                          y: 0,
                          color: context.color.error,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            labelResolver: (_) => 'Ноль',
                            alignment: Alignment.bottomLeft,
                            style: context.text.bodySmall?.copyWith(
                              color: context.color.error,
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

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.risk});

  final PlannerRisk risk;

  @override
  Widget build(BuildContext context) {
    final danger = risk.hasShortfall;
    final accent = danger ? context.color.error : context.color.primary;
    final df = DateFormat('d MMM', 'ru');

    return Card(
      elevation: 0,
      color: context.color.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: danger ? context.color.error : context.color.outlineVariant,
          width: danger ? 1 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  danger
                      ? Icons.warning_amber_rounded
                      : Icons.health_and_safety_outlined,
                  size: 18,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Прогноз рисков',
                  style: context.text.labelLarge?.copyWith(color: accent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (danger)
              _RiskRow(
                icon: Icons.error_outline_rounded,
                color: context.color.error,
                title: 'Кассовый разрыв ${df.format(risk.shortfallDate!)}',
                subtitle: 'дно ${df.format(risk.lowestBalanceDate)}',
                value: risk.lowestBalance,
              )
            else
              _RiskRow(
                icon: Icons.vertical_align_bottom_rounded,
                color: context.color.primary,
                title: 'Дно баланса ${df.format(risk.lowestBalanceDate)}',
                subtitle: risk.bufferDays != null
                    ? 'подушка ~${risk.bufferDays!.round()} дн · '
                        '~${NumberFormat.decimalPattern('ru').format(risk.avgDailyExpense.round())} ₽/день'
                    : null,
                value: risk.lowestBalance,
              ),
            if (risk.longestGap != null) ...[
              const SizedBox(height: 10),
              _RiskRow(
                icon: Icons.timelapse_rounded,
                color: context.color.onSurface,
                title: 'Дольше всего без дохода: ${risk.longestGap!.days} дн',
                subtitle: '${df.format(risk.longestGap!.start)} — '
                    '${df.format(risk.longestGap!.end)}, дно',
                value: risk.longestGap!.lowestBalance,
              ),
            ],
            if (risk.nextGap != null &&
                risk.nextGap!.start != risk.longestGap?.start) ...[
              const SizedBox(height: 10),
              _RiskRow(
                icon: Icons.event_busy_rounded,
                color: context.color.onSurfaceVariant,
                title: 'Ближайший период без дохода: ${risk.nextGap!.days} дн',
                subtitle: 'до ${df.format(risk.nextGap!.end)}, дно',
                value: risk.nextGap!.lowestBalance,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final num value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.bodyMedium),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: context.text.bodySmall?.copyWith(
                    color: context.color.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        MoneyColoredWidget(
          value: value,
          currency: CurrencyDataCommon.rub,
          textStyle: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PeriodsCard extends StatelessWidget {
  const _PeriodsCard({required this.periods});

  final List<PlannerPeriod> periods;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM', 'ru');
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
                Icon(
                  Icons.dashboard_customize_outlined,
                  size: 18,
                  color: context.color.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Периоды по коррекциям',
                  style: context.text.labelLarge
                      ?.copyWith(color: context.color.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < periods.length; i++) ...[
              if (i > 0)
                Divider(height: 16, color: context.color.outlineVariant),
              _PeriodRow(period: periods[i], df: df),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({required this.period, required this.df});

  final PlannerPeriod period;
  final DateFormat df;

  @override
  Widget build(BuildContext context) {
    final low = NumberFormat.compact().format(period.lowestBalance);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          period.startedByCorrection
              ? Icons.flag_outlined
              : Icons.play_arrow_rounded,
          size: 18,
          color: context.color.secondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${df.format(period.start)} — ${df.format(period.end)}',
                style: context.text.bodyMedium,
              ),
              Text(
                'дно $low ₽',
                style: context.text.bodySmall?.copyWith(
                  color: period.hasShortfall
                      ? context.color.error
                      : context.color.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        MoneyColoredWidget(
          value: period.netChange,
          currency: CurrencyDataCommon.rub,
          textStyle: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

int? _findTodayIndex(List<BalancePoint> points) {
  final today = DateTime.now().dayBound;
  for (var i = 0; i < points.length; i++) {
    if (points[i].date.isSameDay(today)) {
      return i;
    }
  }
  return null;
}
