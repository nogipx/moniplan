// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:expressions/expressions.dart';

class PaymentEditScreen extends StatefulWidget {
  final Payment? payment;
  final Function(Payment) onSave;

  const PaymentEditScreen({this.payment, required this.onSave, super.key});

  @override
  State<PaymentEditScreen> createState() => _PaymentEditScreenState();
}

class _PaymentEditScreenState extends State<PaymentEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _taxController;
  late final TextEditingController _noteController;

  DateTime? _date;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isEnabled = true;
  bool _isDone = false;
  DateTimeRepeat _repeatPeriod = DateTimeRepeat.noRepeat;
  PaymentType _type = PaymentType.expense;

  // Для отображения результата вычисления
  String _calculatedAmount = '';
  bool _hasCalculationError = false;

  @override
  void initState() {
    super.initState();

    final payment = widget.payment;

    _titleController = TextEditingController(text: payment?.details.name ?? '');

    _amountController = TextEditingController(
      text: payment?.details.money.toInt().toString() ?? '',
    );

    _taxController = TextEditingController(
      text: ((payment?.details.tax ?? 0) * 100).toInt().toString(),
    );

    _noteController = TextEditingController(text: payment?.details.note ?? '');

    _date = payment?.date ?? DateTime.now();
    _startDate = payment?.dateStart;
    _endDate = payment?.dateEnd;
    _isEnabled = payment?.isEnabled ?? true;
    _isDone = payment?.isDone ?? false;
    _repeatPeriod = payment?.repeat ?? DateTimeRepeat.noRepeat;
    _type = payment?.details.type ?? PaymentType.expense;

    // Добавляем слушатель для обработки арифметических выражений
    _amountController.addListener(_calculateExpression);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _taxController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Метод для вычисления арифметического выражения
  void _calculateExpression() {
    final expression = _amountController.text.trim();

    // Если поле пустое, сбрасываем результат
    if (expression.isEmpty) {
      setState(() {
        _calculatedAmount = '';
        _hasCalculationError = false;
      });
      return;
    }

    // Если в выражении нет операторов, просто показываем число
    if (!_containsOperators(expression)) {
      setState(() {
        _calculatedAmount = '';
        _hasCalculationError = false;
      });
      return;
    }

    try {
      // Заменяем запятые на точки для корректного парсинга
      final sanitizedExpression = expression.replaceAll(',', '.');

      // Создаем экземпляр интерпретатора выражений
      final evaluator = const ExpressionEvaluator();
      final parsed = Expression.parse(sanitizedExpression);

      // Вычисляем результат
      final result = evaluator.eval(parsed, {});

      // Форматируем результат как целое число, если это возможно
      final formattedResult =
          result is double && result == result.truncateToDouble()
              ? result.toInt().toString()
              : result.toString();

      setState(() {
        _calculatedAmount = '= $formattedResult';
        _hasCalculationError = false;
      });
    } catch (e) {
      setState(() {
        _calculatedAmount = 'Ошибка в выражении';
        _hasCalculationError = true;
      });
    }
  }

  // Проверяет, содержит ли строка арифметические операторы
  bool _containsOperators(String text) {
    return text.contains('+') ||
        text.contains('-') && text.indexOf('-') > 0 || // Исключаем отрицательные числа
        text.contains('*') ||
        text.contains('/') ||
        text.contains('(') ||
        text.contains(')');
  }

  Future<void> _selectDate(DateTime? initialDate, Function(DateTime?) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.payment != null ? 'Редактирование платежа' : 'Новый платеж'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _savePayment)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Тип платежа (доход/расход)
            Text('Тип платежа', style: context.text.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<PaymentType>(
              segments: [
                ButtonSegment<PaymentType>(
                  value: PaymentType.expense,
                  label: Text('Расход'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment<PaymentType>(
                  value: PaymentType.income,
                  label: Text('Доход'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<PaymentType> selected) {
                setState(() {
                  _type = selected.first;
                });
              },
            ),

            const SizedBox(height: 16),

            // Название платежа
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Сумма платежа с поддержкой арифметических операций
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Сумма',
                    border: const OutlineInputBorder(),
                    hintText: 'Введите число или выражение (например, 1000+500)',
                    helperText: 'Поддерживаются операции +, -, *, /, скобки',
                    errorText: _hasCalculationError ? 'Ошибка в выражении' : null,
                  ),
                  keyboardType: TextInputType.text,
                ),
                if (_calculatedAmount.isNotEmpty && !_hasCalculationError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                    child: Text(
                      _calculatedAmount,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.color.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Налог
            TextField(
              controller: _taxController,
              decoration: const InputDecoration(
                labelText: 'Налог (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // Примечание
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Примечание',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Дата платежа
            Text('Дата платежа', style: context.text.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              title: Text(_date != null ? DateFormat('d MMMM y').format(_date!) : 'Выберите дату'),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: context.color.outline),
              ),
              onTap:
                  () => _selectDate(_date, (date) {
                    setState(() {
                      _date = date;
                    });
                  }),
            ),

            const SizedBox(height: 24),

            // Повторение платежа
            Text('Повторение', style: context.text.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<DateTimeRepeat>(
              value: _repeatPeriod,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items:
                  DateTimeRepeat.values.map((repeat) {
                    return DropdownMenuItem<DateTimeRepeat>(
                      value: repeat,
                      child: Text(repeat.name),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _repeatPeriod = value;
                  });
                }
              },
            ),

            if (_repeatPeriod != DateTimeRepeat.noRepeat) ...[
              const SizedBox(height: 16),

              // Дата начала повторений
              Text('Дата начала повторений', style: context.text.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                title: Text(
                  _startDate != null
                      ? DateFormat('d MMMM y').format(_startDate!)
                      : 'Выберите дату начала',
                ),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: context.color.outline),
                ),
                onTap:
                    () => _selectDate(_startDate ?? _date, (date) {
                      setState(() {
                        _startDate = date;
                      });
                    }),
              ),

              const SizedBox(height: 16),

              // Дата окончания повторений
              Text('Дата окончания повторений', style: context.text.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                title: Text(
                  _endDate != null
                      ? DateFormat('d MMMM y').format(_endDate!)
                      : 'Выберите дату окончания',
                ),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: context.color.outline),
                ),
                onTap:
                    () => _selectDate(_endDate ?? _date, (date) {
                      setState(() {
                        _endDate = date;
                      });
                    }),
              ),
            ],

            const SizedBox(height: 24),

            // Статус платежа
            Text('Статус платежа', style: context.text.titleMedium),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Активен'),
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Выполнен'),
              value: _isDone,
              onChanged: (value) {
                setState(() {
                  _isDone = value;
                });
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _savePayment() {
    // Проверка на обязательные поля
    if (_titleController.text.isEmpty) {
      showToast('Введите название платежа');
      return;
    }

    if (_amountController.text.isEmpty) {
      showToast('Введите сумму платежа');
      return;
    }

    if (_date == null) {
      showToast('Выберите дату платежа');
      return;
    }

    // Парсинг значений и вычисление выражения, если оно есть
    int? amount;
    final amountText = _amountController.text.trim();

    if (_containsOperators(amountText)) {
      try {
        // Вычисляем арифметическое выражение
        final sanitizedExpression = amountText.replaceAll(',', '.');
        final evaluator = const ExpressionEvaluator();
        final parsed = Expression.parse(sanitizedExpression);
        final result = evaluator.eval(parsed, {});

        // Преобразуем результат в целое число
        amount = result is double ? result.round() : result as int;
      } catch (e) {
        showToast('Ошибка в арифметическом выражении');
        return;
      }
    } else {
      // Обычный парсинг числа
      amount = int.tryParse(amountText);
    }

    if (amount == null) {
      showToast('Некорректная сумма платежа');
      return;
    }

    final int? taxPercent = int.tryParse(_taxController.text);
    if (taxPercent == null) {
      showToast('Некорректный процент налога');
      return;
    }

    final double tax = taxPercent / 100.0;
    if (tax < 0 || tax > 1) {
      showToast('Налог должен быть от 0% до 100%');
      return;
    }

    // Создание или обновление платежа
    final Payment updatedPayment =
        widget.payment?.copyWith(
          isEnabled: _isEnabled,
          isDone: _isDone,
          date: _date!,
          dateStart: _startDate,
          dateEnd: _endDate,
          repeat: _repeatPeriod,
          details: widget.payment!.details.copyWith(
            name: _titleController.text,
            note: _noteController.text,
            money: amount.abs(),
            type: _type,
            tax: tax,
          ),
        ) ??
        Payment(
          paymentId: const Uuid().v4(),
          isEnabled: _isEnabled,
          isDone: _isDone,
          date: _date!,
          dateStart: _startDate,
          dateEnd: _endDate,
          repeat: _repeatPeriod,
          details: PaymentDetails(
            name: _titleController.text,
            note: _noteController.text,
            money: amount.abs(),
            type: _type,
            tax: tax,
            currency: CurrencyDataCommon.rub,
          ),
        );

    // Проверка на возможность применения обновления
    final canApplyUpdate = CheckPaymentCanApplyUpdate(updatedPayment: updatedPayment).run();
    if (!canApplyUpdate.canUpdate) {
      final firstError = canApplyUpdate.errorKeys.firstOrNull;
      var error = 'Невозможно сохранить платеж';

      if (firstError == MoniplanKeys.i.payments.error.requiredDate) {
        error = 'Нужно ввести дату платежа';
      }

      showToast(error);
      return;
    }

    // Сохранение платежа
    widget.onSave(updatedPayment);
    Navigator.pop(context);
  }
}
