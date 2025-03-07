import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/planner/payment_edit_bloc/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_app/features/planner/calculator/_index.dart';

/// Кастомная клавиатура для ввода платежей
class PaymentKeyboard extends StatefulWidget {
  /// Контроллер для текстового поля суммы
  final TextEditingController amountController;

  /// Текущий тип платежа
  final PaymentType paymentType;

  /// Текущая ставка налога
  final double taxRate;

  /// Callback при изменении типа платежа
  final ValueChanged<PaymentType> onPaymentTypeChanged;

  /// Пользовательские кнопки быстрого доступа для суммы
  final List<QuickButton>? amountQuickButtons;

  /// Показывать ли колонку быстрых кнопок
  final bool showQuickButtons;

  /// Находимся ли мы в режиме редактирования существующего платежа
  final bool isEditing;

  /// Начальное значение для сброса (используется только при isEditing = true)
  final String? initialValue;

  const PaymentKeyboard({
    Key? key,
    required this.amountController,
    required this.paymentType,
    required this.onPaymentTypeChanged,
    this.taxRate = 0.0,
    this.amountQuickButtons,
    this.showQuickButtons = true,
    this.isEditing = false,
    this.initialValue,
  }) : super(key: key);

  @override
  State<PaymentKeyboard> createState() => _PaymentKeyboardState();
}

class _PaymentKeyboardState extends State<PaymentKeyboard> {
  // Внутренний контроллер для поля ввода
  late final TextEditingController _internalAmountController;

  // Подписка на поток состояний калькулятора
  StreamSubscription<CalculatorState>? _calculatorStateSubscription;

  // Текущая ставка налога (по умолчанию 0)
  double _currentTaxRate = 0.0;

  @override
  void initState() {
    super.initState();

    // Инициализируем внутренний контроллер
    _internalAmountController = TextEditingController(text: widget.amountController.text);

    // Инициализируем ставку налога из параметра
    _currentTaxRate = widget.taxRate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Подписываемся на изменения состояния калькулятора
    try {
      final calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
      _calculatorStateSubscription?.cancel();
      _calculatorStateSubscription = calculatorBloc.stream.listen((state) {
        _updateControllersFromState(state);
      });
    } catch (e) {
      print('Ошибка при подписке на CalculatorBloc: $e');
    }
  }

  @override
  void didUpdateWidget(PaymentKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Обновляем ставку налога, если она изменилась
    if (widget.taxRate != oldWidget.taxRate) {
      setState(() {
        _currentTaxRate = widget.taxRate;
      });
    }
  }

  @override
  void dispose() {
    // Отменяем подписку на поток состояний
    _calculatorStateSubscription?.cancel();

    // Сохраняем значения из внутреннего контроллера во внешний
    widget.amountController.text = _internalAmountController.text;

    // Освобождаем ресурсы
    _internalAmountController.dispose();
    super.dispose();
  }

  /// Обновляет контроллеры при изменении состояния калькулятора
  void _updateControllersFromState(CalculatorState state) {
    // Обновляем текст только если он изменился
    if (_internalAmountController.text != state.result) {
      // Сохраняем текущую позицию курсора
      final cursorPosition = _internalAmountController.selection.baseOffset;

      // Обновляем текст
      _internalAmountController.text = state.result;

      // Восстанавливаем позицию курсора
      if (cursorPosition >= 0 && cursorPosition <= state.result.length) {
        _internalAmountController.selection = TextSelection.collapsed(offset: cursorPosition);
      } else {
        _internalAmountController.selection = TextSelection.collapsed(offset: state.result.length);
      }
    }
  }

  /// Добавляет цифру к текущему значению
  void _addDigit(String digit) {
    HapticFeedback.lightImpact();

    // Добавляем цифру через блок калькулятора
    try {
      final calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
      calculatorBloc.add(DigitPressed(digit));
    } catch (e) {
      print('Ошибка при добавлении цифры: $e');
    }
  }

  /// Обработчик изменения ставки налога
  void _handleTaxRateChanged(double newRate) {
    setState(() {
      _currentTaxRate = newRate;
    });

    // Отправляем событие в блок редактирования платежа
    try {
      final paymentEditBloc = context.read<PaymentEditBloc>();
      final taxPercent = (newRate * 100).toInt().toString();
      paymentEditBloc.add(PaymentEditTaxChanged(taxPercent));

      // Обновляем черновик платежа
      paymentEditBloc.add(const PaymentEditUpdateDraft());
    } catch (e) {
      print('Ошибка при отправке события в PaymentEditBloc: $e');
    }
  }

  /// Применяет операцию к текущему значению
  void _applyOperation(String operation) {
    HapticFeedback.lightImpact();

    try {
      final calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
      calculatorBloc.add(OperationPressed(operation));
    } catch (e) {
      print('Ошибка при применении операции: $e');
    }
  }

  /// Удаляет последний символ (backspace)
  void _backspace() {
    HapticFeedback.lightImpact();

    try {
      final calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
      calculatorBloc.add(BackspacePressed());
    } catch (e) {
      print('Ошибка при удалении символа: $e');
    }
  }

  /// Устанавливает значение напрямую
  void _setValue(double value) {
    HapticFeedback.lightImpact();

    try {
      // Устанавливаем значение напрямую в контроллер
      _internalAmountController.text = value.toString();
      _internalAmountController.selection = TextSelection.collapsed(
        offset: value.toString().length,
      );

      // Обновляем состояние калькулятора
      final calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
      calculatorBloc.add(SetInitialValue(value.toString()));
    } catch (e) {
      print('Ошибка при установке значения: $e');
    }
  }

  /// Сбрасывает значение на изначальное
  void _resetValue() {
    HapticFeedback.mediumImpact();

    try {
      if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
        // Устанавливаем изначальное значение в контроллер
        _internalAmountController.text = widget.initialValue!;
        _internalAmountController.selection = TextSelection.collapsed(
          offset: widget.initialValue!.length,
        );

        // Обновляем состояние калькулятора
        final calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
        calculatorBloc.add(SetInitialValue(widget.initialValue!));
      }
    } catch (e) {
      print('Ошибка при сбросе значения: $e');
    }
  }

  /// Обрабатывает нажатие кнопки "Готово" или "Дальше"
  void _handleDonePressed(CalculatorState calculatorState) {
    // Сначала применяем операцию "=" для вычисления результата
    try {
      final calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
      calculatorBloc.add(EqualsPressed());
    } catch (e) {
      print('Ошибка при применении операции равенства: $e');
    }

    // Добавляем небольшую задержку для анимации нажатия
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        // Получаем блоки из контекста
        final calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
        final paymentEditBloc = context.read<PaymentEditBloc>();

        // Отправляем события в блок редактирования платежа
        final amount = calculatorBloc.state.result;
        paymentEditBloc.add(PaymentEditAmountChanged(amount));

        // Сохраняем налог
        final taxPercent = (_currentTaxRate * 100).toInt().toString();
        paymentEditBloc.add(PaymentEditTaxChanged(taxPercent));

        // Обновляем черновик платежа
        paymentEditBloc.add(const PaymentEditUpdateDraft());

        // Переходим к следующему шагу
        paymentEditBloc.add(PaymentEditNextStep());
      } catch (e) {
        print('Ошибка при отправке событий в блок: $e');
      }
    });
  }

  /// Обрабатывает нажатие кнопки "="
  void _handleEqualsPressed(CalculatorState calculatorState) {
    // Отправляем событие EqualsPressed вместо OperationPressed('=')
    HapticFeedback.lightImpact();

    try {
      final calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
      calculatorBloc.add(EqualsPressed());
    } catch (e) {
      print('Ошибка при применении операции равенства: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorBlocProvider(
      controller: _internalAmountController,
      child: BlocBuilder<CalculatorBloc, CalculatorState>(
        builder: (context, state) {
          return _buildKeyboard(context, state);
        },
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context, CalculatorState state) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isExpense = widget.paymentType == PaymentType.expense;
    final typeColor = isExpense ? theme.colorScheme.error : theme.colorScheme.primary;
    final typeText = isExpense ? 'Расход' : 'Доход';

    return Container(
      height: MediaQuery.of(context).size.height * KeyboardConstants.keyboardHeightFactor,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(KeyboardConstants.keyboardBorderRadius),
          topRight: Radius.circular(KeyboardConstants.keyboardBorderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Поле ввода и результаты
          InputDisplay(
            state: state,
            paymentType: widget.paymentType,
            amountController: _internalAmountController,
            theme: theme,
            isDarkMode: isDarkMode,
            showTax:
                widget.paymentType == PaymentType.income, // Показываем налог только для доходов
            taxName: 'Налог',
            taxRate: _currentTaxRate,
            onTaxRateChanged: _handleTaxRateChanged,
          ),

          // Ряд с операциями
          OperationsRow(
            onOperationPressed: _applyOperation,
            currentOperator: state.currentOperator,
            theme: theme,
            isDarkMode: isDarkMode,
          ),

          // Клавиатура
          Expanded(
            child: SafeArea(
              child: NumericKeypad(
                onDigitPressed: _addDigit,
                onBackspacePressed: _backspace,
                onQuickValuePressed: _setValue,
                isEditing: widget.isEditing,
                onResetPressed: widget.isEditing ? _resetValue : null,
                theme: theme,
                isDarkMode: isDarkMode,
                calculatorState: state,
                showQuickButtons: widget.showQuickButtons,
                quickButtons: [
                  // Кнопка переключения типа платежа
                  QuickButton(
                    value: 0,
                    text: typeText,
                    backgroundColor: typeColor.withOpacity(0.2),
                    textColor: typeColor,
                    icon: isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                    onPressed: (value, calculatorState) {
                      // Переключаем тип платежа
                      final newType = isExpense ? PaymentType.income : PaymentType.expense;
                      widget.onPaymentTypeChanged(newType);
                      HapticFeedback.mediumImpact();
                    },
                  ),
                  QuickButton(
                    value: 0,
                    text: '=',
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    textColor: theme.colorScheme.primary,
                    onPressed: (value, calculatorState) {
                      _handleEqualsPressed(calculatorState);
                    },
                  ),
                  QuickButton(
                    value: 0,
                    text: 'Дальше',
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    textColor: theme.colorScheme.primary,
                    onPressed: (value, calculatorState) {
                      _handleDonePressed(calculatorState);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
