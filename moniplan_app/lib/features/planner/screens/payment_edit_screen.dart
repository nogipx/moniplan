// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/features/planner/calculator/calculator_bloc/calculator_bloc.dart';
import 'package:moniplan_app/features/planner/calculator/models/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:moniplan_app/features/planner/payment_edit_bloc/_index.dart' as edit;
import 'package:moniplan_app/features/planner/calculator/widgets/payment_keyboard.dart' as keyboard;

class PaymentEditScreen extends StatelessWidget {
  final Payment? payment;
  final Function(Payment) onSave;

  const PaymentEditScreen({this.payment, required this.onSave, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => edit.PaymentEditBloc(onSave: onSave, payment: payment),
      child: const _PaymentEditView(),
    );
  }
}

class _PaymentEditView extends StatelessWidget {
  const _PaymentEditView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<edit.PaymentEditBloc, edit.PaymentEditState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == edit.PaymentEditStatus.success) {
          Navigator.pop(context);
        } else if (state.status == edit.PaymentEditStatus.failure && state.errorMessage != null) {
          showToast(state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.payment != null ? 'Редактирование платежа' : 'Новый платеж',
              style: context.text.headlineSmall,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  () => context.read<edit.PaymentEditBloc>().add(edit.PaymentEditPreviousStep()),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => context.read<edit.PaymentEditBloc>().add(edit.PaymentEditSave()),
                tooltip: 'Сохранить',
              ),
            ],
          ),
          body: _buildBody(context, state),
          bottomNavigationBar:
              state.showKeyboard && state.currentStep != 0
                  ? _buildKeyboard(context, state)
                  : _buildBottomBar(context, state),
          resizeToAvoidBottomInset: false, // Отключаем изменение размера при появлении клавиатуры
          // Добавляем кнопки над системной клавиатурой
          bottomSheet:
              MediaQuery.of(context).viewInsets.bottom > 0
                  ? Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                            onPressed:
                                () => context.read<edit.PaymentEditBloc>().add(
                                  edit.PaymentEditSave(),
                                ),
                            icon: const Icon(Icons.check),
                            label: const Text('Сохранить'),
                          ),
                        ],
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }

  // Основное содержимое экрана
  Widget _buildBody(BuildContext context, edit.PaymentEditState state) {
    return Column(
      children: [
        // Индикатор прогресса
        LinearProgressIndicator(
          value: (state.currentStep + 1) / 3,
          backgroundColor: context.color.surface,
          color: context.color.primary,
        ),

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
        return _buildNameStep(context, state);
      case 2:
        return _buildRepeatStep(context, state);
      default:
        return const SizedBox.shrink();
    }
  }

  // Шаг 1: Ввод суммы
  Widget _buildAmountStep(BuildContext context, edit.PaymentEditState state) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: keyboard.PaymentKeyboard(
          amountController: TextEditingController(text: state.amount),
          paymentType: state.type,
          taxRate: double.tryParse(state.tax) != null ? double.parse(state.tax) / 100 : 0.0,
          onPaymentTypeChanged: (newType) {
            context.read<edit.PaymentEditBloc>().add(edit.PaymentEditTypeChanged(newType));
          },
          onDone: (calculatorState, taxRate) {
            final bloc = context.read<edit.PaymentEditBloc>();
            final amount = calculatorState.result;
            bloc.add(edit.PaymentEditAmountChanged(amount));
            final taxPercent = (taxRate * 100).toInt().toString();
            bloc.add(edit.PaymentEditTaxChanged(taxPercent));
            bloc.add(edit.PaymentEditNextStep());
          },
        ),
      ),
    );
  }

  // Шаг 2: Ввод названия и примечания
  Widget _buildNameStep(BuildContext context, edit.PaymentEditState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Название и примечание', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),

        // Дата платежа
        InkWell(
          onTap:
              () => _selectDate(context, state.date, (date) {
                if (date != null) {
                  context.read<edit.PaymentEditBloc>().add(edit.PaymentEditDateChanged(date));
                }
              }),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Дата платежа', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMMM y').format(state.date),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Поле ввода названия
        TextFormField(
          initialValue: state.title,
          style: theme.textTheme.titleLarge,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Название платежа',
            hintText: 'Введите название',
          ),
          autofocus: false,
          onChanged: (value) {
            context.read<edit.PaymentEditBloc>().add(edit.PaymentEditTitleChanged(value));
          },
        ),

        const SizedBox(height: 24),

        // Поле для примечания
        TextFormField(
          initialValue: state.note,
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
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Text('Платеж выполнен', style: theme.textTheme.titleMedium),
              const Spacer(),
              Switch(
                value: state.isDone,
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

  // Шаг 3: Установка повторения
  Widget _buildRepeatStep(BuildContext context, edit.PaymentEditState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Настройка повторения', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 24),

        // Выбор периода повторения
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
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
                groupValue: state.repeatPeriod,
              ),
              _buildRepeatOption(
                context: context,
                title: 'Ежедневно',
                value: DateTimeRepeat.day,
                groupValue: state.repeatPeriod,
              ),
              _buildRepeatOption(
                context: context,
                title: 'Еженедельно',
                value: DateTimeRepeat.week,
                groupValue: state.repeatPeriod,
              ),
              _buildRepeatOption(
                context: context,
                title: 'Ежемесячно',
                value: DateTimeRepeat.month,
                groupValue: state.repeatPeriod,
              ),
              _buildRepeatOption(
                context: context,
                title: 'Ежегодно',
                value: DateTimeRepeat.year,
                groupValue: state.repeatPeriod,
              ),

              // Поле для ввода кастомного значения периода
              if (state.repeatPeriod.type != DateTimeRepeatType.none) ...[
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
                        initialValue: state.repeatPeriod.value.toString(),
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
                                type: state.repeatPeriod.type,
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
                        state.repeatPeriod.type,
                        int.tryParse(state.repeatPeriod.value.toString()) ?? 1,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        if (state.repeatPeriod.type != DateTimeRepeatType.none) ...[
          const SizedBox(height: 24),

          // Дата начала повторений
          InkWell(
            onTap:
                () => _selectDate(context, state.startDate ?? state.date, (date) {
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
                color: theme.colorScheme.surfaceVariant,
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
                        state.startDate != null
                            ? DateFormat('d MMMM y').format(state.startDate!)
                            : 'Не выбрана',
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
                () => _selectDate(context, state.endDate ?? state.date, (date) {
                  if (date != null) {
                    context.read<edit.PaymentEditBloc>().add(edit.PaymentEditEndDateChanged(date));
                  }
                }),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
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
                        state.endDate != null
                            ? DateFormat('d MMMM y').format(state.endDate!)
                            : 'Не выбрана',
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

  // Клавиатура для ввода суммы и налога
  Widget _buildKeyboard(BuildContext context, edit.PaymentEditState state) {
    return keyboard.PaymentKeyboard(
      amountController: TextEditingController(text: state.amount),
      paymentType: state.type,
      taxRate: double.tryParse(state.tax) != null ? double.parse(state.tax) / 100 : 0.0,
      onPaymentTypeChanged: (newType) {
        context.read<edit.PaymentEditBloc>().add(edit.PaymentEditTypeChanged(newType));
      },
      onDone: (calculatorState, taxRate) {
        final bloc = context.read<edit.PaymentEditBloc>();
        final amount = calculatorState.result;
        bloc.add(edit.PaymentEditAmountChanged(amount));
        final taxPercent = (taxRate * 100).toInt().toString();
        bloc.add(edit.PaymentEditTaxChanged(taxPercent));
        bloc.add(edit.PaymentEditNextStep());
      },
    );
  }

  // Нижняя панель с кнопками навигации
  Widget _buildBottomBar(BuildContext context, edit.PaymentEditState state) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // Кнопка "Назад"
          Expanded(
            child: TextButton.icon(
              onPressed:
                  () => context.read<edit.PaymentEditBloc>().add(edit.PaymentEditPreviousStep()),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Назад'),
            ),
          ),

          // Кнопка "Далее" или "Сохранить"
          Expanded(
            child: FilledButton.icon(
              onPressed: () => context.read<edit.PaymentEditBloc>().add(edit.PaymentEditNextStep()),
              icon: Icon(state.currentStep < 2 ? Icons.arrow_forward : Icons.check),
              label: Text(state.currentStep < 2 ? 'Далее' : 'Сохранить'),
            ),
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
}
