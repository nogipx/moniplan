import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/planner/calculator/_index.dart';
import 'package:moniplan_app/features/planner/payment_edit_bloc/payment_edit_bloc.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:intl/intl.dart';

/// Компонент отображения полей ввода и результатов
class InputDisplay extends StatefulWidget {
  final CalculatorState state;
  final PaymentType paymentType;
  final TextEditingController amountController;
  final ThemeData theme;
  final bool isDarkMode;

  /// Показывать ли налог
  final bool showTax;

  /// Ставка налога (по умолчанию 0%)
  final double taxRate;

  /// Название налога (по умолчанию "Налог")
  final String taxName;

  /// Callback при изменении ставки налога
  final ValueChanged<double>? onTaxRateChanged;

  const InputDisplay({
    Key? key,
    required this.state,
    required this.paymentType,
    required this.amountController,
    required this.theme,
    required this.isDarkMode,
    this.showTax = true,
    this.taxRate = 0.0,
    this.taxName = 'Налог',
    this.onTaxRateChanged,
  }) : super(key: key);

  @override
  State<InputDisplay> createState() => _InputDisplayState();
}

class _InputDisplayState extends State<InputDisplay> {
  // Текущая ставка налога
  late double _currentTaxRate;

  @override
  void initState() {
    super.initState();

    // Инициализируем налог из виджета
    _currentTaxRate = widget.taxRate;

    // Пытаемся получить налог из состояния, если доступно
    try {
      final taxString = context.read<PaymentEditBloc>().state.tax;
      if (taxString.isNotEmpty) {
        // Заменяем запятую на точку для корректного парсинга
        final taxValue = double.tryParse(taxString.replaceAll(',', '.')) ?? 0.0;
        // Преобразуем из процентов в десятичную дробь
        _currentTaxRate = taxValue / 100;
      }
    } catch (e) {
      // Если не удалось получить налог из состояния, используем значение из виджета
      print('Не удалось получить налог из состояния в initState: $e');
    }
  }

  @override
  void didUpdateWidget(InputDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    try {
      // Получаем строковое значение налога из состояния
      final taxString = context.read<PaymentEditBloc>().state.tax;

      // Если строка не пустая, преобразуем её в double и делим на 100 для получения десятичной дроби
      if (taxString.isNotEmpty) {
        // Заменяем запятую на точку для корректного парсинга
        final taxValue = double.tryParse(taxString.replaceAll(',', '.')) ?? 0.0;
        // Преобразуем из процентов в десятичную дробь
        _currentTaxRate = taxValue / 100;
      } else if (widget.taxRate != oldWidget.taxRate) {
        // Если налог из состояния пустой, но изменился taxRate в виджете
        _currentTaxRate = widget.taxRate;
      }
    } catch (e) {
      // В случае ошибки используем значение из виджета
      if (widget.taxRate != oldWidget.taxRate) {
        _currentTaxRate = widget.taxRate;
      }
      print('Ошибка при получении налога из состояния: $e');
    }
  }

  /// Форматирует число с разделителями тысяч
  String _formatNumber(String text) {
    if (text.isEmpty) return '0';

    // Проверяем, содержит ли строка арифметические операторы
    if (text.contains('+') || text.contains('-') || text.contains('×') || text.contains('÷')) {
      // Если есть операторы, возвращаем текст как есть
      return text;
    }

    // Если в строке есть точка, разделяем на целую и дробную части
    if (text.contains('.')) {
      final parts = text.split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      // Форматируем целую часть
      final formatter = NumberFormat('#,###', 'ru_RU');
      String formattedInteger;
      try {
        formattedInteger = integerPart.isEmpty ? '0' : formatter.format(int.parse(integerPart));
      } catch (e) {
        // В случае ошибки возвращаем исходный текст
        return text;
      }

      // Если дробная часть пустая или состоит только из нулей, возвращаем только целую часть
      if (decimalPart.isEmpty || int.tryParse(decimalPart) == 0) {
        return formattedInteger;
      }

      // Возвращаем отформатированное число с дробной частью
      return '$formattedInteger.$decimalPart';
    } else {
      // Если нет дробной части, просто форматируем целое число
      final formatter = NumberFormat('#,###', 'ru_RU');
      try {
        return formatter.format(int.parse(text));
      } catch (e) {
        // В случае ошибки возвращаем исходный текст
        return text;
      }
    }
  }

  /// Результат вычислений и текущий оператор
  Widget _buildCalculationResult(BuildContext context) {
    // Используем цвета из темы приложения
    final Color resultColor =
        widget.paymentType == PaymentType.expense
            ? widget.theme.colorScheme.error
            : widget.theme.colorScheme.primary;
    final Color taxColor = widget.theme.colorScheme.secondary;

    final String sign = widget.paymentType == PaymentType.expense ? '-' : '+';
    final num result = (num.tryParse(widget.state.result) ?? 0).abs();

    // Форматируем результат с разделителями тысяч
    final formatter = NumberFormat('#,###.##', 'ru_RU');

    // Рассчитываем налог (уменьшает итоговую сумму) только для доходов
    final bool isIncome = widget.paymentType == PaymentType.income;
    final bool showTaxInfo = widget.showTax && isIncome;

    final taxAmount = showTaxInfo ? result * _currentTaxRate : 0;
    final netAmount = showTaxInfo ? result - taxAmount : result; // Чистая сумма после вычета налога

    // Форматируем числа, убирая десятичную часть, если она равна нулю
    String formatNumberWithoutTrailingZeros(num value) {
      if (value == value.toInt()) {
        // Если число целое, форматируем как целое
        return formatter.format(value.toInt());
      } else {
        // Иначе форматируем с десятичной частью
        return formatter.format(value);
      }
    }

    final formattedResult = formatNumberWithoutTrailingZeros(result);
    final formattedTax = formatNumberWithoutTrailingZeros(taxAmount);
    final formattedNetAmount = formatNumberWithoutTrailingZeros(netAmount);
    final taxPercent = (_currentTaxRate * 100).toInt();
    final hasTax = _currentTaxRate > 0;

    return Container(
      margin: const EdgeInsets.only(top: KeyboardConstants.defaultPadding),
      padding: const EdgeInsets.all(KeyboardConstants.smallPadding),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
        border: Border.all(color: widget.theme.colorScheme.outline.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Верхняя строка с результатом вычислений
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Информация о налоге (только для доходов)
              if (showTaxInfo)
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showTaxRateDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KeyboardConstants.smallPadding,
                          vertical: KeyboardConstants.tinyPadding,
                        ),
                        decoration: BoxDecoration(
                          color: taxColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hasTax ? '$taxPercent%' : '0%',
                              style: widget.theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.normal,
                                color: taxColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit, size: 14, color: taxColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    if (hasTax)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KeyboardConstants.smallPadding,
                          vertical: KeyboardConstants.tinyPadding,
                        ),
                        decoration: BoxDecoration(
                          color: taxColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '% $formattedTax ₽',
                          style: widget.theme.textTheme.bodyMedium?.copyWith(color: taxColor),
                        ),
                      ),
                  ],
                ),

              // Результат вычислений (без налога или для расходов)
              if (!showTaxInfo || !hasTax)
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KeyboardConstants.smallPadding,
                        vertical: KeyboardConstants.tinyPadding,
                      ),
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$sign $formattedResult ₽',
                        style: widget.theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    ),
                  ),
                ),

              // Результат с учетом налога (только для доходов с налогом)
              if (showTaxInfo && hasTax)
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KeyboardConstants.smallPadding,
                        vertical: KeyboardConstants.tinyPadding,
                      ),
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$sign $formattedNetAmount ₽',
                        style: widget.theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Показывает диалог выбора ставки налога
  void _showTaxRateDialog() {
    final taxRates = [0.0, 0.01, 0.04, 0.06, 0.13];
    final customController = TextEditingController();
    bool isCustomSelected = !taxRates.contains(_currentTaxRate);

    if (isCustomSelected) {
      // Если текущая ставка - пользовательская, заполняем поле ввода
      customController.text = (_currentTaxRate * 100).toStringAsFixed(0);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Выберите ставку налога'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Список предустановленных ставок
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: taxRates.length,
                        itemBuilder: (context, index) {
                          final rate = taxRates[index];
                          final percent = (rate * 100).toInt();
                          final isSelected = rate == _currentTaxRate;

                          return ListTile(
                            title: Text(rate == 0.0 ? 'Без налога' : '$percent%'),
                            trailing:
                                isSelected
                                    ? Icon(Icons.check, color: widget.theme.colorScheme.primary)
                                    : null,
                            selected: isSelected,
                            onTap: () {
                              setState(() {
                                isCustomSelected = false;
                              });

                              this.setState(() {
                                _currentTaxRate = rate;
                              });

                              if (widget.onTaxRateChanged != null) {
                                widget.onTaxRateChanged!(rate);
                              }
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),

                    // Разделитель
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(
                        height: 1,
                        color: widget.theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),

                    // Поле для ввода пользовательской ставки
                    ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: customController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Свой процент',
                                hintText: 'Например: 7',
                                suffixText: '%',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (_) {
                                setState(() {
                                  isCustomSelected = true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.check_circle,
                              color:
                                  isCustomSelected
                                      ? widget.theme.colorScheme.primary
                                      : widget.theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            onPressed: () {
                              final text = customController.text.trim();
                              if (text.isNotEmpty) {
                                final customPercent = int.tryParse(text);
                                if (customPercent != null &&
                                    customPercent >= 0 &&
                                    customPercent <= 99) {
                                  final customRate = customPercent / 100.0;

                                  this.setState(() {
                                    _currentTaxRate = customRate;
                                  });

                                  if (widget.onTaxRateChanged != null) {
                                    widget.onTaxRateChanged!(customRate);
                                  }
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      selected: isCustomSelected,
                      onTap: () {
                        setState(() {
                          isCustomSelected = true;
                        });
                        // Фокусируемся на поле ввода
                        FocusScope.of(context).requestFocus(FocusNode());
                        Future.delayed(Duration(milliseconds: 50), () {
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KeyboardConstants.defaultPadding),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: widget.theme.colorScheme.outline.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Поле ввода суммы
          _buildInputField(label: 'Сумма', controller: widget.amountController, context: context),

          // Результат вычислений и текущий оператор
          _buildCalculationResult(context),
        ],
      ),
    );
  }

  /// Поле ввода суммы
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    final Color fieldColor =
        widget.paymentType == PaymentType.expense
            ? widget.theme.colorScheme.error
            : widget.theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KeyboardConstants.defaultPadding,
        vertical: KeyboardConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
        border: Border.all(color: fieldColor, width: 1),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          // Форматируем значение для отображения
          String rawText = value.text.isEmpty ? '0' : value.text;
          String formattedText = _formatNumber(rawText);

          return Text(
            '$formattedText ₽',
            textAlign: TextAlign.right,
            style: widget.theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: fieldColor,
            ),
          );
        },
      ),
    );
  }
}
