// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/domain/lib/moniplan_domain.dart';
import 'package:moniplan_app/features/calculator/bloc/calculator_bloc.dart';
import 'package:moniplan_app/features/calculator/bloc/calculator_event.dart';
import 'package:moniplan_app/features/calculator/widgets/payment_keyboard.dart' as keyboard;
import 'package:moniplan_app/features/payment_edit/payment_edit_bloc/_index.dart' as edit;
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentEditScreen extends StatefulWidget {
  final Payment? payment;
  final Function(Payment) onSave;

  const PaymentEditScreen({this.payment, required this.onSave, super.key});

  @override
  State<PaymentEditScreen> createState() => _PaymentEditScreenState();
}

class _PaymentEditScreenState extends State<PaymentEditScreen> {
  // Контроллер для калькулятора
  late final TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллер
    if (widget.payment != null) {
      // Получаем сумму платежа
      final money = widget.payment!.details.money.abs();

      // Проверяем, является ли число целым
      final isInteger = money == money.toInt();

      // Форматируем число без десятичной точки для целых чисел
      final formattedMoney = isInteger ? money.toInt().toString() : money.toString();

      amountController = TextEditingController(text: formattedMoney);
    } else {
      amountController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    // Освобождаем ресурсы контроллера
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => edit.PaymentEditBloc(payment: widget.payment)),
        BlocProvider(
          create: (context) {
            // Создаем CalculatorBloc внутри функции create
            final calculatorBloc = CalculatorBloc();

            // Инициализируем блок
            if (amountController.text.isNotEmpty) {
              calculatorBloc.add(SetInitialValue(amountController.text));
            }

            return calculatorBloc;
          },
        ),
      ],
      child: _PaymentEditView(onSave: widget.onSave),
    );
  }
}

class _PaymentEditView extends StatefulWidget {
  final Function(Payment) onSave;

  const _PaymentEditView({required this.onSave});

  @override
  State<_PaymentEditView> createState() => _PaymentEditViewState();
}

class _PaymentEditViewState extends State<_PaymentEditView> {
  // Используем FocusNode для управления фокусом
  final ValueNotifier<bool> shouldAutoFocusKeyboard = ValueNotifier(true);

  @override
  void dispose() {
    shouldAutoFocusKeyboard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<edit.PaymentEditBloc, edit.PaymentEditState>(
      listenWhen: (previous, current) {
        // Слушаем изменения статуса
        return previous.status != current.status;
      },
      listener: (context, state) {
        if (state.status == edit.PaymentEditStatus.success) {
          // Проверяем, что платеж существует
          if (state.payment != null) {
            // Вызываем onSave перед закрытием экрана
            widget.onSave(state.payment!);

            // Добавляем небольшую задержку перед закрытием экрана,
            // чтобы дать время на сохранение платежа
            Future.delayed(const Duration(milliseconds: 300), () {
              // Закрываем экран только если он все еще открыт
              if (context.mounted) {
                Navigator.pop(context);
              }
            });
          }
        } else if (state.status == edit.PaymentEditStatus.failure) {
          // Показываем сообщение об ошибке
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Ошибка при сохранении платежа')),
          );
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            // Показываем диалог подтверждения при попытке выйти
            _showCancelConfirmationDialog(context);
            // Возвращаем false, чтобы предотвратить автоматический выход
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                state.payment != null ? 'Редактирование платежа' : 'Новый платеж',
                style: context.text.headlineSmall,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _showCancelConfirmationDialog(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _savePayment(context, state),
                  tooltip: 'Сохранить',
                ),
              ],
            ),
            // resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                _buildBody(context, state),
                // Показываем панель над клавиатурой
                if (MediaQuery.of(context).viewInsets.bottom > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    // bottom: MediaQuery.of(context).viewInsets.bottom,
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                              },
                              icon: const Icon(Icons.keyboard_hide),
                              label: const Text('Скрыть клавиатуру'),
                            ),
                            FilledButton.icon(
                              onPressed: () => _savePayment(context, state),
                              icon: const Icon(Icons.check),
                              label: const Text('Сохранить'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(context, state),
            bottomSheet: null,
          ),
        );
      },
    );
  }

  // Основное содержимое экрана
  Widget _buildBody(BuildContext context, edit.PaymentEditState state) {
    return Column(
      children: [
        // Основное содержимое в зависимости от текущего шага
        Expanded(
          child:
              state.currentStep == 0
                  ? _buildCurrentStep(context, state)
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildCurrentStep(context, state),
                  ),
        ),
      ],
    );
  }

  // Содержимое текущего шага
  Widget _buildCurrentStep(BuildContext context, edit.PaymentEditState state) {
    switch (state.currentStep) {
      case 0:
        return _buildAmountStep(context, state);
      case 1:
        return _TitleInputStep(state: state, shouldAutoFocusKeyboard: shouldAutoFocusKeyboard);
      case 2:
        return _buildRepeatStep(context, state);
      default:
        return const SizedBox.shrink();
    }
  }

  // Шаг 1: Ввод суммы
  Widget _buildAmountStep(BuildContext context, edit.PaymentEditState state) {
    // Используем сумму из черновика платежа, если он доступен
    String amount;
    if (state.payment != null) {
      // Получаем сумму платежа
      final money = state.payment!.details.money.abs();

      // Проверяем, является ли число целым
      final isInteger = money == money.toInt();

      // Форматируем число без десятичной точки для целых чисел
      amount = isInteger ? money.toInt().toString() : money.toString();
    } else {
      // Проверяем, является ли сумма из состояния целым числом
      final amountValue = double.tryParse(state.amount);
      if (amountValue != null) {
        final isInteger = amountValue == amountValue.toInt();
        amount = isInteger ? amountValue.toInt().toString() : state.amount;
      } else {
        amount = state.amount;
      }
    }

    // Используем тип платежа из черновика, если он доступен
    final paymentType = state.payment != null ? state.payment!.details.type : state.type;

    // Получаем налог из платежа или из состояния
    double taxRate = 0.0;
    if (state.payment != null) {
      taxRate = state.payment!.details.tax;
    } else if (state.tax.isNotEmpty) {
      // Парсим налог из строки, заменяя запятую на точку
      final taxString = state.tax.replaceAll(',', '.');
      taxRate = double.tryParse(taxString) ?? 0.0;
      // Преобразуем из процентов в десятичную дробь
      taxRate = taxRate / 100;
    }

    // Создаем локальный контроллер, если контроллер в блоке null
    final amountController = TextEditingController(text: amount);

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: keyboard.PaymentKeyboard(
          amountController: amountController,
          paymentType: paymentType,
          taxRate: taxRate,
          isEditing: state.payment != null,
          initialValue: state.payment != null ? amount : null,
          onPaymentTypeChanged: (newType) {
            context.read<edit.PaymentEditBloc>().add(edit.PaymentEditTypeChanged(newType));
          },
        ),
      ),
    );
  }

  // Шаг 3: Установка повторения
  Widget _buildRepeatStep(BuildContext context, edit.PaymentEditState state) {
    final theme = Theme.of(context);

    // Всегда используем данные из state, а не из payment
    final repeatPeriod = state.repeatPeriod;
    final startDate = state.startDate;
    final endDate = state.endDate;
    final date = state.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Настройка повторения', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),

        // Выбор периода повторения
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Периодичность', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),

              // Радио-кнопки для выбора периода
              _buildRepeatOption(
                context: context,
                title: 'Без повторения',
                value: DateTimeRepeat.noRepeat,
                groupValue: repeatPeriod,
              ),
              _buildRepeatOption(
                context: context,
                title: 'Ежедневно',
                value: DateTimeRepeat.day,
                groupValue: repeatPeriod,
              ),
              _buildRepeatOption(
                context: context,
                title: 'Еженедельно',
                value: DateTimeRepeat.week,
                groupValue: repeatPeriod,
              ),
              _buildRepeatOption(
                context: context,
                title: 'Ежемесячно',
                value: DateTimeRepeat.month,
                groupValue: repeatPeriod,
              ),
              _buildRepeatOption(
                context: context,
                title: 'Ежегодно',
                value: DateTimeRepeat.year,
                groupValue: repeatPeriod,
              ),

              // Поле для ввода кастомного значения периода
              if (repeatPeriod.type != DateTimeRepeatType.none) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                Text('Укажите период:', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),

                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: repeatPeriod.value.toString(),
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
                            final intValue = int.tryParse(value) ?? 1;
                            if (intValue > 0) {
                              final newRepeat = DateTimeRepeat.custom(
                                type: repeatPeriod.type,
                                value: intValue,
                              );
                              context.read<edit.PaymentEditBloc>().add(
                                edit.PaymentEditRepeatPeriodChanged(newRepeat),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getSuffixText(
                        repeatPeriod.type,
                        int.tryParse(repeatPeriod.value.toString()) ?? 1,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        if (repeatPeriod.type != DateTimeRepeatType.none) ...[
          const SizedBox(height: 24),

          // Дата начала повторений
          InkWell(
            onTap:
                () => _selectDate(context, startDate ?? date, (date) {
                  if (date != null) {
                    context.read<edit.PaymentEditBloc>().add(
                      edit.PaymentEditStartDateChanged(date),
                    );
                  }
                }),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Дата начала повторений', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        startDate != null ? DateFormat('d MMMM y').format(startDate) : 'Не выбрана',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Дата окончания повторений
          InkWell(
            onTap:
                () => _selectDate(context, endDate ?? date, (date) {
                  if (date != null) {
                    context.read<edit.PaymentEditBloc>().add(edit.PaymentEditEndDateChanged(date));
                  }
                }),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Дата окончания повторений', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        endDate != null ? DateFormat('d MMMM y').format(endDate) : 'Не выбрана',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Опция периода повторения
  Widget _buildRepeatOption({
    required BuildContext context,
    required String title,
    required DateTimeRepeat value,
    required DateTimeRepeat groupValue,
  }) {
    return RadioListTile<DateTimeRepeat>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<edit.PaymentEditBloc>().add(edit.PaymentEditRepeatPeriodChanged(newValue));
        }
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  // Выбор даты
  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime?) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    onDateSelected(picked);
  }

  // Нижняя панель с кнопками навигации
  Widget _buildBottomBar(BuildContext context, edit.PaymentEditState state) {
    final theme = Theme.of(context);
    final steps = ['Сумма', 'Название', 'Повторение'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Индикатор прогресса
        LinearProgressIndicator(
          value: (state.currentStep + 1) / 3,
          backgroundColor: theme.colorScheme.surface,
          color: theme.colorScheme.primary,
        ),

        // Навигация по этапам
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(steps.length, (index) {
              final isActive = state.currentStep == index;
              final isCompleted = state.currentStep > index;

              return InkWell(
                onTap: () {
                  _navigateToStep(context, state, index);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Иконка статуса шага
                      if (isCompleted)
                        Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary)
                      else
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    isActive
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Название шага
                      Text(
                        steps[index],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              isActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        // Кнопки действий
        BottomAppBar(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              // Кнопка "Отменить"
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showCancelConfirmationDialog(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Отменить'),
                ),
              ),

              // Кнопка "Сохранить"
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _savePayment(context, state),
                  icon: const Icon(Icons.check),
                  label: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Показывает диалог подтверждения при отмене редактирования
  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Отменить изменения?'),
            content: const Text(
              'Все внесенные изменения будут потеряны. Вы уверены, что хотите выйти без сохранения?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Закрываем диалог
                child: const Text('Продолжить редактирование'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрываем диалог
                  Navigator.of(context).pop(); // Закрываем экран редактирования
                },
                child: const Text('Выйти без сохранения'),
              ),
            ],
          ),
    );
  }

  // Вспомогательный метод для получения текста суффикса в зависимости от типа и значения
  String _getSuffixText(DateTimeRepeatType type, int value) {
    switch (type) {
      case DateTimeRepeatType.day:
        return _getDaysForm(value);
      case DateTimeRepeatType.week:
        return _getWeeksForm(value);
      case DateTimeRepeatType.month:
        return _getMonthsForm(value);
      case DateTimeRepeatType.year:
        return _getYearsForm(value);
      case DateTimeRepeatType.none:
        return '';
    }
  }

  // Вспомогательные методы для склонения существительных
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

  // Метод для сохранения текущего значения из калькулятора
  void _saveCurrentCalculatorValue(BuildContext context, edit.PaymentEditState state) {
    final bloc = context.read<edit.PaymentEditBloc>();

    // Получаем значение из CalculatorBloc
    try {
      final calculatorBloc = context.read<CalculatorBloc>();
      final amount = calculatorBloc.state.result;
      bloc.add(edit.PaymentEditAmountChanged(amount));

      // Обновляем черновик платежа
      bloc.add(const edit.PaymentEditUpdateDraft());
    } catch (e) {
      print('Ошибка при получении значения из CalculatorBloc: $e');

      // Проверяем, что сумма не пустая
      if (state.amount.isEmpty) {
        bloc.add(const edit.PaymentEditAmountChanged('0'));
        bloc.add(const edit.PaymentEditUpdateDraft());
      }
    }
  }

  // Метод для перехода на указанный шаг с сохранением текущих данных
  void _navigateToStep(BuildContext context, edit.PaymentEditState state, int step) {
    // Если мы на шаге ввода суммы, сначала сохраняем текущее значение из калькулятора
    if (state.currentStep == 0) {
      _saveCurrentCalculatorValue(context, state);
    }

    // Переходим на указанный шаг
    context.read<edit.PaymentEditBloc>().add(edit.PaymentEditGoToStep(step));
  }

  // Метод для сохранения платежа с учетом текущего шага
  Future<void> _savePayment(BuildContext context, edit.PaymentEditState state) async {
    // Если мы на шаге ввода суммы, сначала сохраняем текущее значение из калькулятора
    if (state.currentStep == 0) {
      _saveCurrentCalculatorValue(context, state);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Проверяем, что сумма платежа является числом
    final amount = double.tryParse(state.amount);
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сумма платежа должна быть числом')));
      return;
    }

    // Затем сохраняем платеж
    context.read<edit.PaymentEditBloc>().add(edit.PaymentEditSave());
  }
}

class _TitleInputStep extends StatefulWidget {
  final edit.PaymentEditState state;
  final ValueNotifier<bool> shouldAutoFocusKeyboard;

  const _TitleInputStep({required this.state, required this.shouldAutoFocusKeyboard});

  @override
  State<_TitleInputStep> createState() => _TitleInputStepState();
}

class _TitleInputStepState extends State<_TitleInputStep> {
  final _focusNode = FocusNode();

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.shouldAutoFocusKeyboard.value) {
        widget.shouldAutoFocusKeyboard.value = false;
        _focusNode.requestFocus();
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Используем данные из черновика платежа, если он доступен
    final title =
        widget.state.payment != null ? widget.state.payment!.details.name : widget.state.title;
    final note =
        widget.state.payment != null ? widget.state.payment!.details.note : widget.state.note;
    final date = widget.state.payment != null ? widget.state.payment!.date : widget.state.date;
    final isDone =
        widget.state.payment != null ? widget.state.payment!.isDone : widget.state.isDone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Название и примечание', style: context.text.headlineSmall),
        const SizedBox(height: 24),

        // Дата платежа
        InkWell(
          onTap:
              () => _selectDate(context, date, (date) {
                if (date != null) {
                  context.read<edit.PaymentEditBloc>().add(edit.PaymentEditDateChanged(date));
                }
              }),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: context.color.primary),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Дата платежа', style: context.text.bodyMedium),
                    const SizedBox(height: 4),
                    Text(DateFormat('d MMMM y').format(date), style: context.text.titleMedium),
                  ],
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: context.color.onSurfaceVariant),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Поле ввода названия с FocusNode
        TextFormField(
          initialValue: title,
          style: context.text.titleLarge,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Название платежа',
            hintText: 'Введите название',
          ),
          focusNode: _focusNode,
          onChanged: (value) {
            context.read<edit.PaymentEditBloc>().add(edit.PaymentEditTitleChanged(value));
          },
        ),

        const SizedBox(height: 24),

        // Поле для примечания
        TextFormField(
          initialValue: note,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Примечание',
            hintText: 'Необязательно',
          ),
          maxLines: 3,
          onChanged: (value) {
            context.read<edit.PaymentEditBloc>().add(edit.PaymentEditNoteChanged(value));
          },
        ),

        const SizedBox(height: 24),

        // Статус выполнения
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.color.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: context.color.primary),
              const SizedBox(width: 16),
              Text('Платеж выполнен', style: context.text.titleMedium),
              const Spacer(),
              Switch(
                value: isDone,
                onChanged: (value) {
                  context.read<edit.PaymentEditBloc>().add(edit.PaymentEditIsDoneChanged(value));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Выбор даты (копия метода из родительского класса)
  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime?) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    onDateSelected(picked);
  }
}
