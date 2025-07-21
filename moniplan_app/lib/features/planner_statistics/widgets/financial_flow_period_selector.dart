import 'package:flutter/material.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import '../models/financial_flow_analysis_settings.dart';

/// Виджет для выбора периода и настроек анализа финансового потока
class FinancialFlowPeriodSelector extends StatefulWidget {
  const FinancialFlowPeriodSelector({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.isLoading = false,
  });

  final FinancialFlowAnalysisSettings settings;
  final ValueChanged<FinancialFlowAnalysisSettings> onSettingsChanged;
  final bool isLoading;

  @override
  State<FinancialFlowPeriodSelector> createState() =>
      _FinancialFlowPeriodSelectorState();
}

class _FinancialFlowPeriodSelectorState
    extends State<FinancialFlowPeriodSelector> {
  late DateTime _startDate;
  late DateTime _endDate;
  late CalculationStep _calculationStep;
  late CurrencyData _defaultCurrency;

  @override
  void initState() {
    super.initState();
    _updateFromSettings();
  }

  @override
  void didUpdateWidget(FinancialFlowPeriodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _updateFromSettings();
    }
  }

  void _updateFromSettings() {
    _startDate = widget.settings.startDate;
    _endDate = widget.settings.endDate;
    _calculationStep = widget.settings.calculationStep;
    _defaultCurrency = widget.settings.defaultCurrency;
  }

  void _emitChanges() {
    final newSettings = widget.settings.copyWith(
      startDate: _startDate,
      endDate: _endDate,
      calculationStep: _calculationStep,
      defaultCurrency: _defaultCurrency,
    );

    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Настройки анализа',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          
          // Выбор периода
          _buildPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Период анализа',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            // Быстрые пресеты
            _buildQuickPresets(),
            const SizedBox(width: 16),
            
            // Кастомный выбор дат
            Expanded(
              child: _buildCustomDateRange(),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Шаг расчета
        _buildCalculationStepSelector(),
      ],
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрый выбор',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        
        Wrap(
          spacing: 8,
          children: [
            _buildPresetChip('Неделя', _getWeekPeriod),
            _buildPresetChip('Месяц', _getMonthPeriod),
            _buildPresetChip('Квартал', _getQuarterPeriod),
            _buildPresetChip('Год', _getYearPeriod),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: widget.isLoading ? null : onTap,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCustomDateRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Кастомный период',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'От',
                _startDate,
                (date) {
                  setState(() {
                    _startDate = date;
                  });
                  _emitChanges();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDateField(
                'До',
                _endDate,
                (date) {
                  setState(() {
                    _endDate = date;
                  });
                  _emitChanges();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime date,
    ValueChanged<DateTime> onChanged,
  ) {
    return InkWell(
      onTap: widget.isLoading
          ? null
          : () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (pickedDate != null) {
                onChanged(pickedDate);
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              '${date.day}.${date.month}.${date.year}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationStepSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Детализация',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        
        SegmentedButton<CalculationStep>(
          segments: const [
            ButtonSegment(
              value: CalculationStep.daily,
              label: Text('День'),
            ),
            ButtonSegment(
              value: CalculationStep.weekly,
              label: Text('Неделя'),
            ),
            ButtonSegment(
              value: CalculationStep.monthly,
              label: Text('Месяц'),
            ),
          ],
          selected: {_calculationStep},
          onSelectionChanged: widget.isLoading
              ? null
              : (selection) {
                  setState(() {
                    _calculationStep = selection.first;
                  });
                  _emitChanges();
                },
        ),
      ],
    );
  }

  void _getYearPeriod() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, 1, 1);
      _endDate = now;
      _calculationStep = CalculationStep.monthly;
    });
    _emitChanges();
  }

  void _getWeekPeriod() {
    final now = DateTime.now();
    setState(() {
      _startDate = now.subtract(const Duration(days: 7));
      _endDate = now;
      _calculationStep = CalculationStep.daily;
    });
    _emitChanges();
  }

  void _getMonthPeriod() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = now;
      _calculationStep = CalculationStep.weekly;
    });
    _emitChanges();
  }

  void _getQuarterPeriod() {
    final now = DateTime.now();
    final quarterStart = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
    setState(() {
      _startDate = quarterStart;
      _endDate = now;
      _calculationStep = CalculationStep.monthly;
    });
    _emitChanges();
  }
}
