import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_app/features/planner/calculator/_index.dart';

/// Кастомная клавиатура для ввода платежей
class PaymentKeyboard extends StatefulWidget {
  /// Контроллер для текстового поля суммы
  final TextEditingController amountController;

  /// Текущий тип платежа
  final PaymentType paymentType;

  /// Callback при изменении типа платежа
  final ValueChanged<PaymentType> onPaymentTypeChanged;

  /// Callback при нажатии кнопки "Готово"
  final Function(CalculatorState, double) onDone;

  /// Пользовательские кнопки быстрого доступа для суммы
  final List<QuickButton>? amountQuickButtons;

  /// Показывать ли колонку быстрых кнопок
  final bool showQuickButtons;

  /// Текущая ставка налога
  final double taxRate;

  const PaymentKeyboard({
    Key? key,
    required this.amountController,
    required this.paymentType,
    required this.onPaymentTypeChanged,
    required this.onDone,
    this.amountQuickButtons,
    this.showQuickButtons = true,
    this.taxRate = 0.0,
  }) : super(key: key);

  @override
  State<PaymentKeyboard> createState() => _PaymentKeyboardState();
}

class _PaymentKeyboardState extends State<PaymentKeyboard> {
  // Блок калькулятора
  late CalculatorBloc _calculatorBloc;

  // Внутренний контроллер для поля ввода
  late final TextEditingController _internalAmountController;

  // Подписка на поток состояний
  StreamSubscription<CalculatorState>? _calculatorStateSubscription;

  // Текущая ставка налога (по умолчанию берется из виджета)
  late double _taxRate;

  @override
  void initState() {
    super.initState();
    _taxRate = widget.taxRate;
    _initializeControllers();
    _initializeCalculatorBloc();
  }

  @override
  void didUpdateWidget(PaymentKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taxRate != widget.taxRate) {
      setState(() {
        _taxRate = widget.taxRate;
      });
    }
  }

  /// Инициализация контроллеров
  void _initializeControllers() {
    _internalAmountController = TextEditingController(text: widget.amountController.text);
  }

  /// Обработчик изменения ставки налога
  void _handleTaxRateChanged(double newRate) {
    setState(() {
      _taxRate = newRate;
    });
  }

  /// Инициализация блока калькулятора
  void _initializeCalculatorBloc() {
    _calculatorBloc = CalculatorBloc(controller: _internalAmountController);

    final initialValue = _internalAmountController.text;
    if (initialValue.isNotEmpty) {
      _calculatorBloc.add(SetInitialValue(initialValue));
    }

    // Всегда включаем режим калькулятора
    _calculatorBloc.add(const ToggleCalculatorMode(true));

    // Добавляем слушатель для обновления контроллеров при изменении состояния
    _calculatorStateSubscription = _calculatorBloc.stream.listen((state) {
      _updateControllersFromState(state);
    });
  }

  /// Обновляет контроллеры на основе текущего состояния калькулятора
  void _updateControllersFromState(CalculatorState state) {
    // Проверяем, нужно ли обновлять контроллер
    if (_internalAmountController.text != state.result) {
      // Сохраняем текущую позицию курсора
      final cursorPosition = _internalAmountController.selection.baseOffset;

      // Обновляем текст контроллера
      _internalAmountController.text = state.result;

      // Восстанавливаем позицию курсора, если это возможно
      if (cursorPosition >= 0 && cursorPosition <= state.result.length) {
        _internalAmountController.selection = TextSelection.collapsed(offset: cursorPosition);
      } else {
        _internalAmountController.selection = TextSelection.collapsed(offset: state.result.length);
      }
    }

    // Принудительно вызываем перестроение виджета для обновления результатов
    if (mounted) {
      setState(() {});
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
    _calculatorBloc.close();
    super.dispose();
  }

  /// Добавляет цифру к текущему значению
  void _addDigit(String digit) {
    HapticFeedback.lightImpact();

    // Добавляем цифру через блок калькулятора
    _calculatorBloc.add(DigitPressed(digit));
  }

  /// Удаляет последнюю цифру
  void _backspace() {
    HapticFeedback.lightImpact();

    // Удаляем цифру через блок калькулятора
    _calculatorBloc.add(BackspacePressed());
  }

  /// Применяет операцию к текущему значению
  void _applyOperation(String operation) {
    HapticFeedback.mediumImpact();

    // Если операция - это "=", вычисляем результат
    if (operation == '=') {
      _calculatorBloc.add(EqualsPressed());
    } else {
      // Добавляем операцию через блок калькулятора
      _calculatorBloc.add(OperationPressed(operation));
    }
  }

  /// Обрабатывает нажатие на кнопку быстрого значения
  void _onQuickValuePressed(double value) {
    // Очищаем текущее значение
    _calculatorBloc.add(ClearPressed());

    // Устанавливаем новое значение напрямую в контроллер
    _internalAmountController.text = value.toString();
    _internalAmountController.selection = TextSelection.collapsed(offset: value.toString().length);

    // Обновляем состояние калькулятора
    _calculatorBloc.add(UpdateFromController());

    // Добавляем тактильный отклик
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _calculatorBloc,
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
            taxRate: _taxRate,
            taxName: 'Налог',
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
                onQuickValuePressed: _onQuickValuePressed,
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
                    onPressed: (value, calculatorState) async {
                      _applyOperation('=');
                    },
                  ),
                  QuickButton(
                    value: 0,
                    text: 'Дальше',
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    textColor: theme.colorScheme.primary,
                    onPressed: (value, calculatorState) async {
                      _applyOperation('=');
                      await Future.delayed(const Duration(milliseconds: 100));
                      // Передаем информацию о налоге вместе с результатом калькулятора
                      widget.onDone(calculatorState, _taxRate);
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
