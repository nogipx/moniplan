import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import '../models/financial_flow_analysis_settings.dart';

/// Виджет для отображения детального анализа финансового потока (мобильная версия)
class FinancialFlowDetailedAnalysis extends StatelessWidget {
  const FinancialFlowDetailedAnalysis({
    super.key,
    required this.calculation,
    required this.settings,
  });

  final FinancialFlowCalculation calculation;
  final FinancialFlowAnalysisSettings settings;

  /// Форматирует денежную сумму с разделителями тысяч
  String _formatCurrency(num amount, {bool showSign = false}) {
    final formatter = NumberFormat('#,###', 'ru_RU');
    final formattedAmount = formatter.format(amount.abs());

    String result = '$formattedAmount ${settings.defaultCurrency.symbol}';

    if (showSign) {
      if (amount > 0) {
        result = '+$result';
      } else if (amount < 0) {
        result = '-$result';
      }
    } else if (amount < 0) {
      result = '-$result';
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Сводка
          _buildMobileSummaryCard(context),

          // Детализация по периодам
          if (calculation.periodResults.isNotEmpty)
            _buildMobilePeriodsSection(context),

          // Статистика
          _buildMobileStatsSection(context),
        ],
      ),
    );
  }

  Widget _buildMobileSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = calculation.summary.totalNetFlow >= 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isPositive
                  ? [
                    colorScheme.primaryContainer.withOpacity(0.3),
                    colorScheme.primaryContainer.withOpacity(0.5),
                  ]
                  : [
                    colorScheme.errorContainer.withOpacity(0.3),
                    colorScheme.errorContainer.withOpacity(0.5),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isPositive
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Итоговый поток
          Text(
            'Итоговый поток',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(calculation.summary.totalNetFlow, showSign: true),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPositive ? colorScheme.primary : colorScheme.error,
            ),
          ),

          const SizedBox(height: 20),

          // Доходы и расходы
          Row(
            children: [
              Expanded(
                child: _buildMobileSummaryItem(
                  context,
                  'Доходы',
                  calculation.summary.totalIncome.toDouble(),
                  Colors.green,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildMobileSummaryItem(
                  context,
                  'Расходы',
                  calculation.summary.totalExpenses.toDouble(),
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Периодов: ${calculation.periodResults.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color:
                color == Colors.green ? colorScheme.primary : colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePeriodsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: ExpansionTile(
          leading: Icon(
            Icons.timeline,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'Динамика по периодам',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${calculation.periodResults.length} периодов'),
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: calculation.periodResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final period = calculation.periodResults[index];
                  return _buildMobilePeriodItem(context, period);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePeriodItem(
    BuildContext context,
    PeriodCalculationResult period,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final netFlow = period.totalIncome - period.totalExpenses;
    final isPositive = netFlow >= 0;
    final maxAmount = [
      period.totalIncome,
      period.totalExpenses,
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isPositive
                  ? [
                    colorScheme.primaryContainer.withOpacity(0.2),
                    colorScheme.primaryContainer.withOpacity(0.4),
                  ]
                  : [
                    colorScheme.errorContainer.withOpacity(0.2),
                    colorScheme.errorContainer.withOpacity(0.4),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isPositive
                  ? colorScheme.primary.withOpacity(0.2)
                  : colorScheme.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок периода
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatPeriodLabel(
                  period.period.startDate,
                  period.period.endDate,
                ),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isPositive
                          ? colorScheme.primary.withOpacity(0.2)
                          : colorScheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatCurrency(netFlow, showSign: true),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPositive ? colorScheme.primary : colorScheme.error,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Визуальные индикаторы доходов и расходов
          Column(
            children: [
              _buildFlowBar(
                context,
                'Доходы',
                period.totalIncome,
                maxAmount,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildFlowBar(
                context,
                'Расходы',
                period.totalExpenses,
                maxAmount,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowBar(
    BuildContext context,
    String label,
    num amount,
    num maxAmount,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage =
        maxAmount > 0 ? (amount / maxAmount).clamp(0.0, 1.0) : 0.0;

    // Определяем цвета на основе темы
    final barColor =
        color == Colors.green ? colorScheme.primary : colorScheme.error;
    final textColor =
        color == Colors.green ? colorScheme.primary : colorScheme.error;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: barColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            _formatCurrency(amount),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStatsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Статистика',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildMobileStatItem(
                context,
                'Инструментов',
                '${_getTotalInstruments()}',
                Icons.account_balance_wallet,
              ),

              const SizedBox(height: 12),

              _buildMobileStatItem(
                context,
                'Средний доход в месяц',
                _formatCurrency(calculation.summary.averageMonthlyIncome),
                Icons.trending_up,
              ),

              const SizedBox(height: 12),

              _buildMobileStatItem(
                context,
                'Средние расходы в месяц',
                _formatCurrency(calculation.summary.averageMonthlyExpenses),
                Icons.trending_down,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
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
          'янв',
          'фев',
          'мар',
          'апр',
          'май',
          'июн',
          'июл',
          'авг',
          'сен',
          'окт',
          'ноя',
          'дек',
        ];
        return '${months[start.month - 1]} ${start.year}';
    }
  }
}
