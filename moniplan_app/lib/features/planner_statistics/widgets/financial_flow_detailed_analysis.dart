import 'package:flutter/material.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import '../models/financial_flow_analysis_settings.dart';

/// Виджет для отображения детального анализа финансового потока
class FinancialFlowDetailedAnalysis extends StatelessWidget {
  const FinancialFlowDetailedAnalysis({
    super.key,
    required this.calculation,
    required this.settings,
  });

  final FinancialFlowCalculation calculation;
  final FinancialFlowAnalysisSettings settings;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Сводка
          _buildSummaryCard(context),
          const SizedBox(height: 16),
          
          // Детализация по периодам
          _buildPeriodsBreakdown(context),
          const SizedBox(height: 16),
          
          // Анализ инструментов
          _buildInstrumentsAnalysis(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сводка за период',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Доходы',
                    calculation.summary.totalIncome.toDouble(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Расходы',
                    calculation.summary.totalExpenses.toDouble(),
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: calculation.summary.totalNetFlow >= 0
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: calculation.summary.totalNetFlow >= 0
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Итоговый поток',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${calculation.summary.totalNetFlow >= 0 ? '+' : ''}${calculation.summary.totalNetFlow.toStringAsFixed(2)} ${settings.defaultCurrency.symbol}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: calculation.summary.totalNetFlow >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Периодов проанализировано: ${calculation.periodResults.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} ${settings.defaultCurrency.symbol}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildPeriodsBreakdown(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Динамика по периодам',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Простая визуализация периодов
            ...calculation.periodResults.take(10).map((period) {
              return _buildPeriodItem(context, period);
            }).toList(),
            
            if (calculation.periodResults.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'И еще ${calculation.periodResults.length - 10} периодов...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodItem(BuildContext context, PeriodCalculationResult period) {
    final netFlow = period.totalIncome - period.totalExpenses;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatPeriodLabel(period.period.startDate, period.period.endDate),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          
          Expanded(
            child: Text(
              '+${period.totalIncome.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.green[700]),
              textAlign: TextAlign.center,
            ),
          ),
          
          Expanded(
            child: Text(
              '-${period.totalExpenses.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
          ),
          
          Expanded(
            child: Text(
              '${netFlow >= 0 ? '+' : ''}${netFlow.toStringAsFixed(0)}',
              style: TextStyle(
                color: netFlow >= 0 ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstrumentsAnalysis(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика инструментов',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Всего инструментов: ${_getTotalInstruments()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Средний доход за период: ${calculation.summary.averageMonthlyIncome.toStringAsFixed(2)} ${settings.defaultCurrency.symbol}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Средние расходы за период: ${calculation.summary.averageMonthlyExpenses.toStringAsFixed(2)} ${settings.defaultCurrency.symbol}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalInstruments() {
    final allInstruments = <String>{};
    for (final period in calculation.periodResults) {
      for (final instrument in period.instrumentResults) {
        allInstruments.add(instrument.instrumentId);
      }
    }
    return allInstruments.length;
  }

  String _formatPeriodLabel(DateTime start, DateTime end) {
    switch (settings.calculationStep) {
      case CalculationStep.daily:
        return '${start.day}.${start.month}.${start.year}';
      case CalculationStep.weekly:
        return '${start.day}.${start.month} - ${end.day}.${end.month}';
      case CalculationStep.monthly:
        final months = [
          'янв', 'фев', 'мар', 'апр', 'май', 'июн',
          'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
        ];
        return '${months[start.month - 1]} ${start.year}';
    }
  }
}
