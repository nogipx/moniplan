import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import '../bloc/statistics_bloc.dart';
import '_index.dart';
import 'package:moniplan_app/features/planner/widgets/money_flow_widget.dart';

class PlannerStatisticsScreen extends StatelessWidget {
  final String plannerId;

  const PlannerStatisticsScreen({super.key, required this.plannerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => StatisticsBloc(
            repository: AppDi.instance.getStatisticsRepo(),
            plannerId: plannerId,
            log: AppLog('StatisticsBloc'),
          )..add(const StatisticsEvent.started()),
      child: const PlannerStatisticsView(),
    );
  }
}

class PlannerStatisticsView extends StatelessWidget {
  const PlannerStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.surface,
      appBar: AppBar(
        title: Text('Monistat', style: context.text.displaySmall),
        centerTitle: true,
        actions: [
          // Переключатель режима просмотра
          BlocBuilder<StatisticsBloc, StatisticsState>(
            buildWhen: (previous, current) {
              return previous.maybeMap(
                loaded:
                    (previousLoaded) => current.maybeMap(
                      loaded:
                          (currentLoaded) =>
                              previousLoaded.showCompletedOnly != currentLoaded.showCompletedOnly,
                      orElse: () => false,
                    ),
                orElse: () => false,
              );
            },
            builder: (context, state) {
              final showCompletedOnly = state.maybeMap(
                loaded: (loaded) => loaded.showCompletedOnly,
                orElse: () => true,
              );

              return IconButton(
                icon: Icon(
                  showCompletedOnly ? Icons.check_circle : Icons.calendar_today_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip:
                    showCompletedOnly
                        ? 'Отображаются выполненные платежи'
                        : 'Отображаются все платежи',
                onPressed: () {
                  context.read<StatisticsBloc>().add(
                    StatisticsEvent.viewModeChanged(showCompletedOnly: !showCompletedOnly),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const SizedBox(),
            loading: (_) => const Center(child: CircularProgressIndicator.adaptive()),
            loaded: (loaded) {
              return _StatisticsContent(
                statistics: loaded.statistics,
                showCompletedOnly: loaded.showCompletedOnly,
              );
            },
            error:
                (error) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: context.color.error),
                      const SizedBox(height: 16),
                      Text('Ошибка загрузки данных', style: context.text.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        error.message,
                        style: context.text.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<StatisticsBloc>().add(
                            const StatisticsEvent.refreshRequested(),
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Попробовать снова'),
                      ),
                    ],
                  ),
                ),
          );
        },
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  final BudgetStatistics statistics;
  final bool showCompletedOnly;

  const _StatisticsContent({required this.statistics, required this.showCompletedOnly});

  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Нет данных для отображения'),
          ],
        ),
      );
    }

    // Фильтруем данные в зависимости от выбранного режима
    final dates = statistics.totalBudget.keys.toList()..sort();
    final filteredDates =
        showCompletedOnly
            ? dates.where((date) => statistics.totalBudget[date]?.allCompleted == true).toList()
            : dates;

    // Если после фильтрации нет данных, показываем сообщение
    if (filteredDates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showCompletedOnly ? Icons.check_circle_outline : Icons.calendar_today_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет ${showCompletedOnly ? "выполненных" : ""} транзакций для отображения',
              textAlign: TextAlign.center,
              style: context.text.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<StatisticsBloc>().add(
                  StatisticsEvent.viewModeChanged(showCompletedOnly: !showCompletedOnly),
                );
              },
              icon: Icon(
                showCompletedOnly ? Icons.calendar_today_outlined : Icons.check_circle_outline,
              ),
              label: Text(
                'Показать ${showCompletedOnly ? "все" : "только выполненные"} транзакции',
              ),
            ),
          ],
        ),
      );
    }

    // Создаем вспомогательные наборы данных только для отфильтрованных дат
    final filteredTotalBudget = <DateTime, ({num totalBudget, bool allCompleted})>{};
    final filteredIncomes = <DateTime, num>{};
    final filteredExpenses = <DateTime, num>{};
    final filteredCorrections = <DateTime, num>{};

    for (final date in filteredDates) {
      if (statistics.totalBudget.containsKey(date)) {
        filteredTotalBudget[date] = statistics.totalBudget[date]!;
      }

      if (statistics.incomes.containsKey(date)) {
        filteredIncomes[date] = statistics.incomes[date]!;
      }

      if (statistics.expenses.containsKey(date)) {
        filteredExpenses[date] = statistics.expenses[date]!;
      }

      if (statistics.corrections.containsKey(date)) {
        filteredCorrections[date] = statistics.corrections[date]!;
      }
    }

    // Создаем отфильтрованную статистику
    final filteredStatistics = BudgetStatistics(
      totalBudget: filteredTotalBudget,
      incomes: filteredIncomes,
      expenses: filteredExpenses,
      corrections: filteredCorrections,
    );

    // Получаем сводную информацию на основе отфильтрованных данных
    final flowResult = StatisticsMoneyFlowAdapter.fromStatistics(filteredStatistics);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Статистические показатели
            _buildStatSummary(context, flowResult, showCompletedOnly),

            // График
            _BudgetTrendsSection(
              statistics: filteredStatistics,
              showCompletedOnly: showCompletedOnly,
            ),

            // Таблица операций
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: MoneyFlowWidget(state: flowResult),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummary(
    BuildContext context,
    MoneyFlowUseCaseResult flowResult,
    bool showCompletedOnly,
  ) {
    final positiveColor = context.ext<MoniplanExtraColors>()?.moneyPositive ?? Colors.green;
    final negativeColor = context.ext<MoniplanExtraColors>()?.moneyNegative ?? Colors.red;

    // Рассчитаем основные статистические параметры
    final totalDays = filteredStatistics.totalBudget.length;
    final variance = _calculateVariance(
      filteredStatistics.totalBudget.values.map((e) => e.totalBudget).toList(),
    );
    final stdDev = sqrt(variance);

    // Рассчитаем темп роста
    final growthRate = _calculateGrowthRate(filteredStatistics.totalBudget);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика',
              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            // Метка режима просмотра
            Row(
              children: [
                Icon(
                  showCompletedOnly ? Icons.check_circle_outline : Icons.calendar_today_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  showCompletedOnly
                      ? 'Только выполненные платежи'
                      : 'Все платежи (включая будущие)',
                  style: context.text.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Первый ряд: базовые показатели
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Доходы',
                    value: flowResult.totalIncome,
                    icon: Icons.arrow_upward_rounded,
                    color: positiveColor,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Расходы',
                    value: flowResult.totalOutcome,
                    icon: Icons.arrow_downward_rounded,
                    color: negativeColor,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Баланс',
                    value: flowResult.balance,
                    icon: Icons.account_balance_wallet_rounded,
                    color: flowResult.balance >= 0 ? positiveColor : negativeColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Второй ряд: статистические показатели
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Стд. откл.',
                    value: stdDev,
                    icon: Icons.show_chart,
                    color: Colors.blue[700] ?? Colors.blue,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Медиана',
                    value: _calculateMedian(
                      filteredStatistics.totalBudget.values.map((e) => e.totalBudget).toList(),
                    ),
                    icon: Icons.linear_scale,
                    color: Colors.purple[700] ?? Colors.purple,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Темп роста',
                    value: growthRate,
                    icon: growthRate >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: growthRate >= 0 ? positiveColor : negativeColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Третий ряд: дополнительные показатели
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Мин. знач.',
                    value: filteredStatistics.totalBudget.values
                        .map((e) => e.totalBudget)
                        .reduce((a, b) => a < b ? a : b),
                    icon: Icons.keyboard_double_arrow_down,
                    color: Colors.teal[700] ?? Colors.teal,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Макс. знач.',
                    value: filteredStatistics.totalBudget.values
                        .map((e) => e.totalBudget)
                        .reduce((a, b) => a > b ? a : b),
                    icon: Icons.keyboard_double_arrow_up,
                    color: Colors.amber[800] ?? Colors.amber,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Периодов',
                    value: totalDays,
                    icon: Icons.calendar_today,
                    color: Colors.blueGrey[700] ?? Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательный параметр для _buildStatSummary
  BudgetStatistics get filteredStatistics {
    if (!showCompletedOnly) return statistics;

    final dates = statistics.totalBudget.keys.toList()..sort();
    final filteredDates =
        dates.where((date) => statistics.totalBudget[date]?.allCompleted == true).toList();

    // Создаем вспомогательные наборы данных только для отфильтрованных дат
    final filteredTotalBudget = <DateTime, ({num totalBudget, bool allCompleted})>{};
    final filteredIncomes = <DateTime, num>{};
    final filteredExpenses = <DateTime, num>{};
    final filteredCorrections = <DateTime, num>{};

    for (final date in filteredDates) {
      if (statistics.totalBudget.containsKey(date)) {
        filteredTotalBudget[date] = statistics.totalBudget[date]!;
      }

      if (statistics.incomes.containsKey(date)) {
        filteredIncomes[date] = statistics.incomes[date]!;
      }

      if (statistics.expenses.containsKey(date)) {
        filteredExpenses[date] = statistics.expenses[date]!;
      }

      if (statistics.corrections.containsKey(date)) {
        filteredCorrections[date] = statistics.corrections[date]!;
      }
    }

    return BudgetStatistics(
      totalBudget: filteredTotalBudget,
      incomes: filteredIncomes,
      expenses: filteredExpenses,
      corrections: filteredCorrections,
    );
  }

  // Функции для расчета статистических показателей
  double _calculateVariance(List<num> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumSquaredDiff = values.fold<double>(0, (sum, val) => sum + pow(val - mean, 2));
    return sumSquaredDiff / values.length;
  }

  num _calculateMedian(List<num> values) {
    if (values.isEmpty) return 0;

    final sorted = List<num>.from(values)..sort();
    final middle = sorted.length ~/ 2;

    if (sorted.length % 2 == 1) {
      return sorted[middle];
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2;
    }
  }

  double _calculateGrowthRate(Map<DateTime, ({num totalBudget, bool allCompleted})> budgetData) {
    if (budgetData.isEmpty || budgetData.length < 2) return 0;

    final dates = budgetData.keys.toList()..sort();
    final firstValue = budgetData[dates.first]!.totalBudget;
    final lastValue = budgetData[dates.last]!.totalBudget;

    if (firstValue == 0) return 0;

    return ((lastValue - firstValue) / firstValue.abs()) * 100;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final num value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currency = CurrencyDataCommon.rub;
    final text = value.currency(currency);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _BudgetTrendsSection extends StatelessWidget {
  final BudgetStatistics statistics;
  final bool showCompletedOnly;

  const _BudgetTrendsSection({required this.statistics, required this.showCompletedOnly});

  @override
  Widget build(BuildContext context) {
    final dates = statistics.totalBudget.keys.toList()..sort();

    if (dates.isEmpty) {
      return const SizedBox();
    }

    final minDate = dates.first;
    final maxDate = dates.last;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'График данных',
              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '${DateFormat('d MMM', 'ru').format(minDate)} — ${DateFormat('d MMM', 'ru').format(maxDate)}',
              style: context.text.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 16),

            // Упрощенный график
            SizedBox(height: 180, child: _SimpleChartView(statistics: statistics)),

            const SizedBox(height: 16),
            _buildKeyMetrics(context),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context) {
    // Суммируем доходы и расходы
    final totalIncome = statistics.incomes.values.fold<num>(0, (sum, value) => sum + value);

    final totalExpense = statistics.expenses.values.fold<num>(0, (sum, value) => sum + value);

    final daysCount = statistics.totalBudget.length;
    final averageIncomePerDay = daysCount > 0 ? totalIncome / daysCount : 0;
    final averageExpensePerDay = daysCount > 0 ? totalExpense / daysCount : 0;

    final positiveColor = context.ext<MoniplanExtraColors>()?.moneyPositive ?? Colors.green;
    final negativeColor = context.ext<MoniplanExtraColors>()?.moneyNegative ?? Colors.red;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _MetricChip(
          icon: Icons.trending_up_rounded,
          label: 'Ср. доход',
          value: '${averageIncomePerDay.toStringAsFixed(0)} ₽/д',
          color: positiveColor,
        ),
        const SizedBox(width: 16),
        _MetricChip(
          icon: Icons.trending_down_rounded,
          label: 'Ср. расход',
          value: '${averageExpensePerDay.toStringAsFixed(0)} ₽/д',
          color: negativeColor,
        ),
      ],
    );
  }
}

/// Упрощенный график для предпросмотра
class _SimpleChartView extends StatelessWidget {
  final BudgetStatistics statistics;

  const _SimpleChartView({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final allDates = statistics.totalBudget.keys.toList()..sort();

    if (allDates.isEmpty) {
      return const Center(child: Text('Нет данных'));
    }

    final minDate = allDates.first;
    final maxDate = allDates.last;
    final now = DateTime.now();

    // Получаем все значения бюджета для всех дат
    final budgetValues =
        allDates.map((date) => statistics.totalBudget[date]!.totalBudget.toDouble()).toList();

    final maxY = budgetValues.isEmpty ? 1000.0 : budgetValues.reduce((a, b) => a > b ? a : b) * 1.1;
    final minY = budgetValues.isEmpty ? 0.0 : budgetValues.reduce((a, b) => a < b ? a : b) * 0.9;

    // Создаем точки графика баланса для всех дат
    final balanceSpots = <FlSpot>[];

    for (final date in allDates) {
      balanceSpots.add(
        FlSpot(
          date.millisecondsSinceEpoch.toDouble(),
          statistics.totalBudget[date]!.totalBudget.toDouble(),
        ),
      );
    }

    balanceSpots.sort((a, b) => a.x.compareTo(b.x));

    // Ищем ближайший день к текущему среди всех дат
    DateTime nearestDate = allDates.first;
    int minDiff = (now.difference(allDates.first).inMilliseconds).abs();

    for (final date in allDates) {
      final diff = (now.difference(date).inMilliseconds).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearestDate = date;
      }
    }

    final nearestDateMs = nearestDate.millisecondsSinceEpoch.toDouble();
    final positiveColor = context.ext<MoniplanExtraColors>()?.moneyPositive ?? Colors.green;
    final lineColor = Colors.blueGrey[800] ?? Colors.blueGrey;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: false,
          drawVerticalLine: true,
          verticalInterval: 86400000 * 30, // примерно 1 месяц
          getDrawingVerticalLine: (value) {
            // Выделяем текущий день (или ближайший)
            final isNearestDay = (value - nearestDateMs).abs() < 43200000; // 12 часов

            return FlLine(
              color:
                  isNearestDay
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                      : Colors.transparent,
              strokeWidth: isNearestDay ? 1.5 : 0,
              dashArray: isNearestDay ? [4, 4] : null,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (maxDate.millisecondsSinceEpoch - minDate.millisecondsSinceEpoch) / 3,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                final isNearestDay = (value - nearestDateMs).abs() < 43200000;

                return Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    DateFormat('MMM', 'ru').format(date),
                    style: context.text.bodySmall?.copyWith(
                      fontSize: 9,
                      color: isNearestDay ? Theme.of(context).colorScheme.primary : null,
                      fontWeight: isNearestDay ? FontWeight.bold : null,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: minDate.millisecondsSinceEpoch.toDouble(),
        maxX: maxDate.millisecondsSinceEpoch.toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(12),
            tooltipMargin: 8,
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());

                // Находим соответствующие данные для этой даты
                final income = statistics.incomes[date]?.toDouble() ?? 0.0;
                final expense = statistics.expenses[date]?.toDouble() ?? 0.0;
                final balance = spot.y;
                final isNearestDay = (spot.x - nearestDateMs).abs() < 43200000;
                final isCompleted = statistics.totalBudget[date]?.allCompleted == true;

                // Более информативный тултип
                return LineTooltipItem(
                  DateFormat('d MMMM yyyy', 'ru').format(date),
                  context.text.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isNearestDay ? Theme.of(context).colorScheme.primary : null,
                      ) ??
                      const TextStyle(fontWeight: FontWeight.bold),
                  children: [
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: 'Статус: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: isCompleted ? 'Выполнено' : 'Запланировано',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color:
                            isCompleted
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: 'Доход: ',
                      style: TextStyle(color: positiveColor, fontWeight: FontWeight.normal),
                    ),
                    TextSpan(text: '$income ₽\n'),
                    TextSpan(
                      text: 'Расход: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(text: '$expense ₽\n'),
                    TextSpan(
                      text: 'Баланс: ',
                      style: TextStyle(color: lineColor, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '$balance ₽', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: balanceSpots,
            isCurved: false,
            color: lineColor,
            barWidth: 2,
            isStrokeCapRound: false,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) {
                // Показываем точку для текущего или ближайшего дня
                return (spot.x - nearestDateMs).abs() < 43200000;
              },
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: lineColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: true, color: lineColor.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.text.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              Text(
                value,
                style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
