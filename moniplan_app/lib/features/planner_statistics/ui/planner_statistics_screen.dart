import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_core/src/features/statistic/statistics_repository.dart';
import 'package:moniplan_core/moniplan_core.dart';
import '../bloc/statistics_bloc.dart';
import 'planner_chart.dart';

class PlannerStatisticsScreen extends StatelessWidget {
  final String plannerId;

  const PlannerStatisticsScreen({
    super.key,
    required this.plannerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatisticsBloc(
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
      appBar: AppBar(
        title: const Text('Статистика бюджета'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StatisticsBloc>().add(
                    const StatisticsEvent.refreshRequested(),
                  );
            },
          ),
        ],
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const SizedBox(),
            loading: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
            loaded: (loaded) {
              return Column(
                children: [
                  _PeriodSelector(
                    onPeriodChanged: (start, end) {
                      context.read<StatisticsBloc>().add(
                            StatisticsEvent.periodChanged(
                              startDate: start,
                              endDate: end,
                            ),
                          );
                    },
                  ),
                  if (loaded.statistics.isEmpty)
                    const Center(
                      child: Text('Нет данных за выбранный период'),
                    )
                  else
                    Expanded(
                      child: PlannerChart(
                        totalBudget: loaded.statistics.totalBudget,
                        incomes: loaded.statistics.incomes,
                        expenses: loaded.statistics.expenses,
                      ),
                    ),
                ],
              );
            },
            error: (error) => Center(
              child: Text('Ошибка: ${error.message}'),
            ),
          );
        },
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final void Function(DateTime? startDate, DateTime? endDate) onPeriodChanged;

  const _PeriodSelector({
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PeriodButton(
            title: 'Неделя',
            onTap: () => _selectPeriod(Days.week),
          ),
          _PeriodButton(
            title: 'Месяц',
            onTap: () => _selectPeriod(Days.month),
          ),
          _PeriodButton(
            title: 'Год',
            onTap: () => _selectPeriod(Days.year),
          ),
          _PeriodButton(
            title: 'Все',
            onTap: () => _selectPeriod(null),
          ),
        ],
      ),
    );
  }

  void _selectPeriod(int? days) {
    if (days == null) {
      onPeriodChanged(null, null);
      return;
    }
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    onPeriodChanged(start, end);
  }
}

class _PeriodButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(title),
    );
  }
}

abstract class Days {
  static const week = 7;
  static const month = 30;
  static const year = 365;
}
