// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

import '../../planner_statistics/screens/financial_flow_analysis_screen.dart';

class AdvancedFinancialFlowWidget extends StatelessWidget {
  final Planner planner;

  const AdvancedFinancialFlowWidget({super.key, required this.planner});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.color.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.color.outlineVariant, width: 0.5),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.insights_rounded,
          color: context.color.primary,
          size: 20,
        ),
        title: Text(
          'Анализ финансового потока',
          style: context.text.titleSmall?.copyWith(
            color: context.color.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Детальный анализ доходов и расходов',
          style: context.text.bodySmall?.copyWith(
            color: context.color.onSurfaceVariant,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<FinancialFlowCalculation>(
              future: _calculateFinancialFlow(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: context.color.error,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ошибка при расчете финансового потока',
                          style: context.text.bodyMedium?.copyWith(
                            color: context.color.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final calculation = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Основная сводка
                    _buildSummarySection(context, calculation),

                    const SizedBox(height: 16),

                    // Детализация по периодам
                    if (calculation.periodResults.length > 1) ...[
                      _buildPeriodsSection(context, calculation),
                      const SizedBox(height: 16),
                    ],

                    // Анализ инструментов
                    _buildInstrumentsSection(context, calculation),

                    const SizedBox(height: 16),

                    // Кнопка перехода к полному анализу
                    _buildAnalysisButton(context, planner),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<FinancialFlowCalculation> _calculateFinancialFlow() async {
    // Создаем профиль финансового потока из планировщика
    final adapter = PaymentToFinancialInstrumentAdapter();
    final profile = adapter.createProfileFromPlanner(planner);

    // Вычисляем финансовый поток
    final calculationService = FinancialFlowCalculationServiceImpl();
    return calculationService.calculateFinancialFlow(profile);
  }

  Widget _buildSummarySection(
    BuildContext context,
    FinancialFlowCalculation calculation,
  ) {
    final summary = calculation.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Общая сводка',
          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                context,
                'Общий доход',
                summary.totalIncome,
                Icons.trending_up_rounded,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryItem(
                context,
                'Общий расход',
                summary.totalExpenses,
                Icons.trending_down_rounded,
                isPositive: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        _buildSummaryItem(
          context,
          'Чистый поток',
          summary.totalNetFlow,
          summary.totalNetFlow >= 0
              ? Icons.check_circle_rounded
              : Icons.warning_rounded,
          isPositive: summary.totalNetFlow >= 0,
          isHighlighted: true,
        ),

        if (calculation.periodResults.length > 1) ...[
          const SizedBox(height: 8),
          _buildAverageFlow(context, summary),
        ],
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    num value,
    IconData icon, {
    bool isPositive = true,
    bool isHighlighted = false,
  }) {
    final color =
        isPositive
            ? context.ext<MoniplanExtraColors>()?.moneyPositive ?? Colors.green
            : context.ext<MoniplanExtraColors>()?.moneyNegative ?? Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isHighlighted
                ? context.color.primaryContainer.withOpacity(0.3)
                : context.color.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isHighlighted
                  ? context.color.primary.withOpacity(0.3)
                  : context.color.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: context.text.bodySmall?.copyWith(
                    color: context.color.onSurfaceVariant,
                    fontWeight: isHighlighted ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          MoneyColoredWidget(
            value: value,
            currency: CurrencyDataCommon.rub,
            showPlusSign: true,
            textStyle: context.text.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            ),
            overridePositiveColor: color,
            overrideNegativeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildAverageFlow(BuildContext context, CalculationSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildAverageItem(
            context,
            'Средний доход/мес',
            summary.averageMonthlyIncome,
            Icons.calendar_month_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildAverageItem(
            context,
            'Средний расход/мес',
            summary.averageMonthlyExpenses,
            Icons.calendar_month_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildAverageItem(
    BuildContext context,
    String label,
    num value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.color.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: context.color.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: context.text.bodySmall?.copyWith(
                    color: context.color.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          MoneyColoredWidget(
            value: value,
            currency: CurrencyDataCommon.rub,
            textStyle: context.text.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodsSection(
    BuildContext context,
    FinancialFlowCalculation calculation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'По периодам (${calculation.periodResults.length} мес.)',
          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: calculation.periodResults.length,
            itemBuilder: (context, index) {
              final period = calculation.periodResults[index];
              final isPositive = period.netFlow >= 0;

              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.color.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.color.outlineVariant),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'М${index + 1}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.color.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color:
                          isPositive
                              ? context
                                  .ext<MoniplanExtraColors>()
                                  ?.moneyPositive
                              : context
                                  .ext<MoniplanExtraColors>()
                                  ?.moneyNegative,
                    ),
                    const SizedBox(height: 2),
                    MoneyColoredWidget(
                      value: period.netFlow,
                      currency: CurrencyDataCommon.rub,
                      textStyle: context.text.bodySmall?.copyWith(fontSize: 11),
                      showPlusSign: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstrumentsSection(
    BuildContext context,
    FinancialFlowCalculation calculation,
  ) {
    final incomes = calculation.profile.incomes;
    final expenses = calculation.profile.expenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Состав портфеля',
          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildInstrumentsList(
                context,
                'Доходы',
                incomes,
                Icons.add_circle_outline,
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInstrumentsList(
                context,
                'Расходы',
                expenses,
                Icons.remove_circle_outline,
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstrumentsList(
    BuildContext context,
    String title,
    List<FinancialInstrument> instruments,
    IconData icon,
    bool isIncome,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.color.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    isIncome
                        ? context.ext<MoniplanExtraColors>()?.moneyPositive
                        : context.ext<MoniplanExtraColors>()?.moneyNegative,
              ),
              const SizedBox(width: 6),
              Text(
                '$title (${instruments.length})',
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.color.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (instruments.isEmpty) ...[
            Text(
              'Нет данных',
              style: context.text.bodySmall?.copyWith(
                color: context.color.onSurfaceVariant.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            ...instruments
                .take(3)
                .map(
                  (instrument) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            instrument.name,
                            style: context.text.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        MoneyColoredWidget(
                          value: instrument.amount,
                          currency: instrument.currency,
                          textStyle: context.text.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            if (instruments.length > 3) ...[
              Text(
                '... и ещё ${instruments.length - 3}',
                style: context.text.bodySmall?.copyWith(
                  fontSize: 10,
                  color: context.color.onSurfaceVariant.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisButton(BuildContext context, Planner planner) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      FinancialFlowAnalysisScreen(plannerId: planner.id),
            ),
          );
        },
        icon: const Icon(Icons.analytics_outlined, size: 18),
        label: const Text('Подробный анализ'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
