// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class RepeatPeriodSelector extends StatefulWidget {
  final DateTimeRepeat initialValue;
  final ValueChanged<DateTimeRepeat> onChanged;

  const RepeatPeriodSelector({super.key, required this.initialValue, required this.onChanged});

  @override
  State<RepeatPeriodSelector> createState() => _RepeatPeriodSelectorState();
}

class _RepeatPeriodSelectorState extends State<RepeatPeriodSelector> {
  late DateTimeRepeat _selectedRepeat;
  late DateTimeRepeatType _selectedType;
  late int _customValue;
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRepeat = widget.initialValue;
    _selectedType = _selectedRepeat.type;
    _customValue = _selectedRepeat.value;
    _valueController.text = _customValue > 0 ? _customValue.toString() : '';
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _updateRepeat() {
    if (_selectedType == DateTimeRepeatType.none) {
      setState(() {
        _selectedRepeat = DateTimeRepeat.noRepeat;
      });
      widget.onChanged(_selectedRepeat);
      return;
    }

    final int value = int.tryParse(_valueController.text) ?? 1;
    if (value <= 0) return;

    final newRepeat = DateTimeRepeat.custom(type: _selectedType, value: value);
    setState(() {
      _selectedRepeat = newRepeat;
      _customValue = value;
    });
    widget.onChanged(_selectedRepeat);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Выбор типа повторения с помощью чипов
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildRepeatChip(DateTimeRepeat.noRepeat, 'Без повторения', Icons.block),
            _buildRepeatChip(DateTimeRepeat.day, 'Ежедневно', Icons.today),
            _buildRepeatChip(DateTimeRepeat.week, 'Еженедельно', Icons.view_week),
            _buildRepeatChip(DateTimeRepeat.month, 'Ежемесячно', Icons.calendar_month),
            _buildRepeatChip(DateTimeRepeat.year, 'Ежегодно', Icons.calendar_today),
          ],
        ),

        if (_selectedType != DateTimeRepeatType.none) ...[
          const SizedBox(height: 16),

          // Пользовательское значение в более компактном виде
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    hintText: '1',
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _updateRepeat();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(_getSuffixText(), style: context.text.bodyMedium),
            ],
          ),

          const SizedBox(height: 16),

          // Информационный блок с выбранным периодом
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: context.color.primaryContainer.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.color.primary.withAlpha(100), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.repeat, color: context.color.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Выбрано: ${_selectedRepeat.displayName}',
                    style: context.text.bodyMedium?.copyWith(color: context.color.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRepeatChip(DateTimeRepeat option, String label, IconData icon) {
    final isSelected = _selectedRepeat.type == option.type;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? context.color.onPrimaryContainer : context.color.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRepeat = option;
            _selectedType = option.type;
            _customValue = option.value;
            _valueController.text = option.value > 0 ? option.value.toString() : '';
          });
          widget.onChanged(_selectedRepeat);
        }
      },
      backgroundColor: context.color.surfaceContainerLow,
      selectedColor: context.color.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  String _getSuffixText() {
    switch (_selectedType) {
      case DateTimeRepeatType.day:
        return _getDaysForm(_customValue);
      case DateTimeRepeatType.week:
        return _getWeeksForm(_customValue);
      case DateTimeRepeatType.month:
        return _getMonthsForm(_customValue);
      case DateTimeRepeatType.year:
        return _getYearsForm(_customValue);
      case DateTimeRepeatType.none:
        return '';
    }
  }

  String _getDaysForm(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(days % 10) && ![12, 13, 14].contains(days % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }

  String _getWeeksForm(int weeks) {
    if (weeks % 10 == 1 && weeks % 100 != 11) {
      return 'неделя';
    } else if ([2, 3, 4].contains(weeks % 10) && ![12, 13, 14].contains(weeks % 100)) {
      return 'недели';
    } else {
      return 'недель';
    }
  }

  String _getMonthsForm(int months) {
    if (months % 10 == 1 && months % 100 != 11) {
      return 'месяц';
    } else if ([2, 3, 4].contains(months % 10) && ![12, 13, 14].contains(months % 100)) {
      return 'месяца';
    } else {
      return 'месяцев';
    }
  }

  String _getYearsForm(int years) {
    if (years % 10 == 1 && years % 100 != 11) {
      return 'год';
    } else if ([2, 3, 4].contains(years % 10) && ![12, 13, 14].contains(years % 100)) {
      return 'года';
    } else {
      return 'лет';
    }
  }
}
