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
  bool _isCustomPeriod = false;
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
    final settings = FinancialFlowAnalysisSettings(
      startDate: _startDate,
      endDate: _endDate,
      calculationStep: _calculationStep,
      defaultCurrency: _defaultCurrency,
      isCustomPeriod: _isCustomPeriod,
    );
    widget.onSettingsChanged(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Быстрые пресеты
          _buildQuickPresets(),
          const SizedBox(height: 12),

          // Детализация
          _buildCalculationStepSelector(),
        ],
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Период',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip('Неделя', _getWeekPeriod),
              const SizedBox(width: 8),
              _buildPresetChip('Месяц', _getMonthPeriod),
              const SizedBox(width: 8),
              _buildPresetChip('Квартал', _getQuarterPeriod),
              const SizedBox(width: 8),
              _buildPresetChip('Год', _getYearPeriod),
              const SizedBox(width: 8),
              _buildCustomButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    final isSelected = _isPresetSelected(label);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: widget.isLoading ? null : (_) => onTap(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildCustomButton() {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 16),
          const SizedBox(width: 4),
          Text(_getDateRangeText()),
        ],
      ),
      onPressed: widget.isLoading ? null : _showDatePicker,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildCalculationStepSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Детализация расчета',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        SegmentedButton<CalculationStep>(
          segments: const [
            ButtonSegment(value: CalculationStep.daily, label: Text('День')),
            ButtonSegment(value: CalculationStep.weekly, label: Text('Неделя')),
            ButtonSegment(value: CalculationStep.monthly, label: Text('Месяц')),
          ],
          selected: {_calculationStep},
          onSelectionChanged:
              widget.isLoading
                  ? null
                  : (selection) {
                    setState(() {
                      _calculationStep = selection.first;
                    });
                    _emitChanges();
                  },
          style: SegmentedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
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

  bool _isPresetSelected(String preset) {
    final now = DateTime.now();

    switch (preset) {
      case 'Неделя':
        final weekStart = now.subtract(const Duration(days: 7));
        // Точное сравнение дат (с точностью до дня)
        return _isSameDay(_startDate, weekStart) && _isSameDay(_endDate, now);

      case 'Месяц':
        final monthStart = DateTime(now.year, now.month, 1);
        return _isSameDay(_startDate, monthStart) && _isSameDay(_endDate, now);

      case 'Квартал':
        final quarterStart = DateTime(
          now.year,
          ((now.month - 1) ~/ 3) * 3 + 1,
          1,
        );
        return _isSameDay(_startDate, quarterStart) &&
            _isSameDay(_endDate, now);

      case 'Год':
        final yearStart = DateTime(now.year, 1, 1);
        return _isSameDay(_startDate, yearStart) && _isSameDay(_endDate, now);

      default:
        return false;
    }
  }

  /// Проверяет, что две даты одинаковые (игнорируя время)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDateRangeText() {
    return '${_startDate.day}.${_startDate.month} - ${_endDate.day}.${_endDate.month}';
  }

  Future<void> _showDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _isCustomPeriod = true;
      });
      _emitChanges();
    }
  }

  void _getWeekPeriod() {
    final now = DateTime.now();
    setState(() {
      _startDate = now.subtract(const Duration(days: 7));
      _endDate = now;
      _calculationStep = CalculationStep.daily;
      _isCustomPeriod = false;
    });
    _emitChanges();
  }

  void _getMonthPeriod() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = now;
      _calculationStep = CalculationStep.weekly;
      _isCustomPeriod = false;
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
      _isCustomPeriod = false;
    });
    _emitChanges();
  }
}
