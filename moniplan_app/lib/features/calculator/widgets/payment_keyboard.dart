import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/calculator/_index.dart';
import 'package:moniplan_app/features/payment_edit/payment_edit_bloc/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

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
    required this.amountController,
    required this.paymentType,
    required this.onPaymentTypeChanged,
    this.taxRate = 0.0,
    this.amountQuickButtons,
    this.showQuickButtons = true,
    this.isEditing = false,
    this.initialValue,
    super.key,
  });

  @override
  State<PaymentKeyboard> createState() => _PaymentKeyboardState();
}

class _PaymentKeyboardState extends State<PaymentKeyboard> {
  // Внутренний контроллер для поля ввода
  late final TextEditingController _internalAmountController;

  // Подписка на поток состояний калькулятора
  StreamSubscription<CalculatorState>? _calculatorStateSubscription;

  // Текущая ставка налога (по умолчанию 0)
  double _currentTaxRate = 0;

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
      _calculatorStateSubscription = calculatorBloc.stream.listen(_updateControllersFromState);
    } on Object catch (e) {
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
      BlocProvider.of<CalculatorBloc>(context).add(DigitPressed(digit));
    } on Object catch (e) {
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
      paymentEditBloc
        ..add(PaymentEditTaxChanged(taxPercent))
        // Обновляем черновик платежа
        ..add(const PaymentEditUpdateDraft());
    } on Object catch (e) {
      print('Ошибка при отправке события в PaymentEditBloc: $e');
    }
  }

  /// Удаляет последний символ (backspace)
  void _backspace() {
    HapticFeedback.lightImpact();

    try {
      BlocProvider.of<CalculatorBloc>(context).add(BackspacePressed());
    } on Object catch (e) {
      print('Ошибка при удалении символа: $e');
    }
  }

  /// Очищает значение
  void _clear() {
    HapticFeedback.mediumImpact();

    try {
      // Устанавливаем изначальное значение в контроллер
      _internalAmountController.text = '';
      _internalAmountController.selection = const TextSelection.collapsed(offset: 0);

      // Обновляем состояние калькулятора
      BlocProvider.of<CalculatorBloc>(context).add(ClearPressed());
    } on Object catch (e) {
      print('Ошибка при сбросе значения: $e');
    }
  }

  /// Обрабатывает нажатие кнопки "Готово" или "Дальше"
  void _handleDonePressed(BuildContext context, CalculatorState calculatorState) {
    // Сначала применяем операцию "=" для вычисления результата
    try {
      BlocProvider.of<CalculatorBloc>(context).add(EqualsPressed());
    } on Object catch (e) {
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
        paymentEditBloc
          ..add(PaymentEditTaxChanged(taxPercent))
          // Обновляем черновик платежа
          ..add(const PaymentEditUpdateDraft())
          // Переходим к следующему шагу
          ..add(PaymentEditNextStep());
      } on Object catch (e) {
        print('Ошибка при отправке событий в блок: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorBlocProvider(
      initialValue: _internalAmountController.text,
      child: BlocBuilder<CalculatorBloc, CalculatorState>(builder: _buildKeyboard),
    );
  }

  Widget _buildKeyboard(BuildContext context, CalculatorState state) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isExpense = widget.paymentType == PaymentType.expense;
    final typeColor = isExpense ? context.color.secondary : context.color.primary;
    final typeText = isExpense ? 'Расход' : 'Доход';

    return SizedBox(
      height: MediaQuery.of(context).size.height * KeyboardConstants.keyboardHeightFactor,
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
            taxRate: _currentTaxRate,
            onTaxRateChanged: _handleTaxRateChanged,
          ),

          // Ряд с операциями
          OperationsRow(
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
                onClearPressed: widget.isEditing ? _clear : null,
                isEditing: widget.isEditing,
                theme: theme,
                isDarkMode: isDarkMode,
                calculatorState: state,
                showQuickButtons: widget.showQuickButtons,
                quickButtons: [
                  // Кнопка переключения типа платежа
                  QuickButton(
                    text: typeText,
                    backgroundColor: typeColor.withValues(alpha: 0.2),
                    textColor: typeColor,
                    borderColor: Colors.transparent,
                    icon: isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                    onPressed: (calculatorState) {
                      final newType = isExpense ? PaymentType.income : PaymentType.expense;
                      widget.onPaymentTypeChanged(newType);
                      HapticFeedback.mediumImpact();
                    },
                  ),
                  QuickButton(
                    text: 'Дальше',
                    backgroundColor: context.color.tertiaryContainer.withValues(alpha: 0.2),
                    textColor: context.color.onTertiaryContainer,
                    borderColor: context.color.tertiaryContainer,
                    onPressed: (calculatorState) {
                      _handleDonePressed(context, calculatorState);
                      HapticFeedback.heavyImpact();
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
