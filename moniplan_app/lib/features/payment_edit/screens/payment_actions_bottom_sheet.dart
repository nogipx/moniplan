// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/domain/moniplan_domain.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/payment_edit/screens/payment_edit_screen.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentActionsBottomSheet extends StatefulWidget {
  final Payment payment;
  final Function()? onDelete;
  final Function()? onMove;
  final Function()? onFixation;
  final Function(Payment)? onToggleEnabled;
  final Function(Payment)? onToggleDone;
  final PlannerBloc? plannerBloc;
  final bool isVirtualPaymentSelected;

  const PaymentActionsBottomSheet({
    required this.payment,
    this.onDelete,
    this.onMove,
    this.onFixation,
    this.onToggleEnabled,
    this.onToggleDone,
    this.plannerBloc,
    this.isVirtualPaymentSelected = false,
    super.key,
  });

  static Future<void> show({
    required BuildContext context,
    required Payment payment,
    Function()? onDelete,
    Function()? onMove,
    Function()? onFixation,
    Function(Payment)? onToggleEnabled,
    Function(Payment)? onToggleDone,
    bool isVirtualPaymentSelected = false,
  }) async {
    final plannerBloc = BlocProvider.of<PlannerBloc>(context, listen: false);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BlocProvider.value(
            value: plannerBloc,
            child: PaymentActionsBottomSheet(
              payment: payment,
              onDelete: onDelete,
              onMove: onMove,
              onFixation: onFixation,
              onToggleEnabled: onToggleEnabled,
              onToggleDone: onToggleDone,
              plannerBloc: plannerBloc,
              isVirtualPaymentSelected: isVirtualPaymentSelected,
            ),
          ),
    );
  }

  @override
  State<PaymentActionsBottomSheet> createState() => _PaymentActionsBottomSheetState();
}

class _PaymentActionsBottomSheetState extends State<PaymentActionsBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moneyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    final isIncome = widget.payment.type == PaymentType.income;
    final moneyColor = isIncome ? context.color.primary : context.color.error;
    final moneySign = isIncome ? '+' : '-';
    final moneyValue = moneyFormat.format(widget.payment.normalizedMoney.abs());

    // Определяем, является ли платеж реальным (не виртуальным)
    final isRealPayment = widget.payment.isParent;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: context.color.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: context.color.shadow.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Верхняя полоска для перетаскивания
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.color.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Заголовок с названием и суммой
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название платежа
                  Text(
                    widget.payment.details.name,
                    style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.visible,
                  ),

                  // Индикатор виртуального платежа
                  if (widget.payment.isNotParent) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: context.color.tertiary),
                        const SizedBox(width: 8),
                        Text(
                          'Виртуальный платеж из повторяющейся серии',
                          style: context.text.bodySmall?.copyWith(
                            color: context.color.tertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ] else if (widget.isVirtualPaymentSelected) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: context.color.tertiary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Родительский платеж для выбранного виртуального платежа',
                            style: context.text.bodySmall?.copyWith(
                              color: context.color.tertiary,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Дата платежа (обычный текст без возможности тапа)
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: context.color.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('d MMMM y').format(widget.payment.date),
                        style: context.text.bodyMedium?.copyWith(
                          color: context.color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Сумма платежа (перемещена влево)
                  Text(
                    '$moneySign$moneyValue',
                    style: context.text.headlineMedium?.copyWith(
                      color: moneyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Налог (только для доходов)
                  if (isIncome && widget.payment.details.tax > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.percent, size: 16, color: context.color.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'Налог: ${(widget.payment.details.tax * 100).toInt()}%',
                          style: context.text.bodySmall?.copyWith(
                            color: context.color.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Предсказанная категория (если есть)
                  const SizedBox(height: 12),

                  // Информация о повторении платежа
                  if (widget.payment.isRepeat) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.repeat, size: 16, color: context.color.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Повторяется: ${_getRepeatText(widget.payment.repeat)}',
                            style: context.text.bodySmall?.copyWith(
                              color: context.color.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Период повторения
                    if (widget.payment.dateStart != null || widget.payment.dateEnd != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.date_range, size: 16, color: context.color.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getRepeatPeriodText(widget.payment),
                              style: context.text.bodySmall?.copyWith(
                                color: context.color.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  // Статус платежа (только для реальных платежей)
                  if (isRealPayment) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          widget.payment.isEnabled
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          size: 16,
                          color:
                              widget.payment.isEnabled
                                  ? context.color.primary
                                  : context.color.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.payment.isEnabled ? 'Активен' : 'Отключен',
                          style: context.text.bodySmall?.copyWith(
                            color:
                                widget.payment.isEnabled
                                    ? context.color.primary
                                    : context.color.error,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (!widget.payment.isRepeat) ...[
                          Icon(
                            widget.payment.isDone ? Icons.task_alt : Icons.pending_outlined,
                            size: 16,
                            color:
                                widget.payment.isDone
                                    ? context.color.primary
                                    : context.color.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.payment.isDone ? 'Выполнен' : 'Не выполнен',
                            style: context.text.bodySmall?.copyWith(
                              color:
                                  widget.payment.isDone
                                      ? context.color.primary
                                      : context.color.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // Примечание к платежу (если есть)
                  if (widget.payment.details.note.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, size: 16, color: context.color.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.payment.details.note,
                            style: context.text.bodySmall?.copyWith(
                              color: context.color.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1),

            // Основные кнопки действий
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.onMove != null)
                    _buildCircleButton(
                      context,
                      icon: Icons.date_range,
                      label: 'Перенести',
                      color: context.color.secondary,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onMove?.call();
                      },
                    ),

                  // Кнопки включения/выключения и выполнения только для реальных платежей
                  if (isRealPayment && widget.onToggleEnabled != null)
                    _buildCircleButton(
                      context,
                      icon:
                          !widget.payment.isEnabled
                              ? Icons.power_settings_new_rounded
                              : Icons.power_settings_new_outlined,
                      label: !widget.payment.isEnabled ? 'Выключено' : 'Включено',
                      color:
                          !widget.payment.isEnabled
                              ? context.color.tertiary
                              : context.color.primary,
                      onTap: () {
                        widget.onToggleEnabled?.call(
                          widget.payment.copyWith(isEnabled: !widget.payment.isEnabled),
                        );
                        Navigator.pop(context);
                      },
                    ),

                  if (widget.onToggleDone != null)
                    _buildCircleButton(
                      context,
                      icon: !widget.payment.isDone ? Icons.remove_done : Icons.done,
                      label: !widget.payment.isDone ? 'Не выполнено' : 'Выполнено',
                      color:
                          !widget.payment.isDone ? context.color.tertiary : context.color.primary,
                      onTap: () {
                        // Показываем диалог о необходимости фиксации перед выполнением платежа
                        // в двух случаях:
                        // 1. Если был выбран виртуальный платеж (даже если отображается родительский)
                        // 2. Если платеж реальный и является родителем повторяющихся платежей
                        if (!widget.payment.isDone &&
                            widget.payment.isRepeat &&
                            (widget.isVirtualPaymentSelected || widget.payment.isRepeatParent)) {
                          _showFixationBeforeCompletionDialog(context);
                        } else {
                          widget.onToggleDone?.call(
                            widget.payment.copyWith(isDone: !widget.payment.isDone),
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),

                  if (widget.onDelete != null)
                    _buildCircleButton(
                      context,
                      icon: Icons.delete_outline,
                      label: 'Удалить',
                      color: context.color.error,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onDelete?.call();
                      },
                    ),
                ],
              ),
            ),

            // Кнопка редактирования внизу
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_downward_rounded),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.surfaceContainerLow,
                        foregroundColor: context.color.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PaymentEditScreen(
                                  payment: widget.payment,
                                  onSave: (updatedPayment) async {
                                    await onSave(updatedPayment);
                                  },
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Изменить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.primaryContainer,
                        foregroundColor: context.color.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PaymentEditScreen(
                                  payment: widget.payment.copyBaseData(),
                                  onSave: (updatedPayment) async {
                                    await onSave(updatedPayment);
                                  },
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.surfaceContainerLow,
                        foregroundColor: context.color.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Кнопка фиксации для повторяющихся платежей
            if (widget.payment.isRepeat && widget.onFixation != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextButton.icon(
                  onPressed: () {
                    _showFixationDialog(context);
                  },
                  icon: const Icon(Icons.lock_clock),
                  label: const Text('Зафиксировать повторяющийся платеж'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.color.tertiary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> onSave(Payment updatedPayment) async {
    try {
      // Проверяем доступность PlannerBloc
      final bloc = widget.plannerBloc;
      if (bloc == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка: PlannerBloc недоступен')));
        return;
      }

      // Создаем Completer для ожидания результата операции
      final completer = Completer<bool>();

      // Подписываемся на состояние блока планировщика
      late final StreamSubscription<PlannerState> subscription;
      subscription = bloc.stream.listen((state) {
        // Если в состоянии есть ошибки, считаем операцию неуспешной
        if (state.errors.isNotEmpty) {
          subscription.cancel();
          completer.complete(false);
          return;
        }

        // Проверяем, содержит ли состояние наш платеж
        if (state is PlannerBudgetComputedState) {
          final paymentExists = state.payments.any((p) => p.paymentId == updatedPayment.paymentId);
          if (paymentExists) {
            subscription.cancel();
            completer.complete(true);
            return;
          }
        }
      });

      // Устанавливаем таймаут на операцию
      Future.delayed(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.complete(true); // Предполагаем успех по таймауту
        }
      });

      // Отправляем событие обновления платежа в блок планировщика
      bloc.add(
        PlannerEvent.updatePayment(
          newPayment: updatedPayment,
          create: updatedPayment.paymentId.isEmpty,
        ),
      );

      // Ждем результат операции
      final success = await completer.future;

      // Показываем сообщение об ошибке, если операция не удалась
      if (!success && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Не удалось сохранить платеж')));
      }
    } catch (e) {
      print('Ошибка при сохранении платежа: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка при сохранении платежа: $e')));
      }
    }
  }

  // Показывает диалог с пояснением о фиксации повторяющегося платежа
  void _showFixationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Фиксация повторяющегося платежа'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'При фиксации повторяющегося платежа произойдет следующее:',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildFixationInfoItem(
                context,
                icon: Icons.repeat_one,
                text: 'Текущий платеж станет обычным (не повторяющимся)',
              ),
              const SizedBox(height: 8),
              _buildFixationInfoItem(
                context,
                icon: Icons.calendar_today,
                text: 'Будущие повторения останутся в календаре',
              ),
              const SizedBox(height: 8),
              _buildFixationInfoItem(
                context,
                icon: Icons.edit_calendar,
                text: 'Вы сможете редактировать этот платеж отдельно от других повторений',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
                widget.onFixation?.call(); // Вызываем функцию фиксации
                Navigator.of(context).pop(); // Закрываем нижний лист
              },
              child: const Text('Зафиксировать'),
            ),
          ],
        );
      },
    );
  }

  // Показывает диалог о необходимости фиксации перед выполнением платежа
  void _showFixationBeforeCompletionDialog(BuildContext context) {
    final String titleText =
        widget.isVirtualPaymentSelected
            ? 'Необходима фиксация виртуального платежа'
            : 'Необходима фиксация повторяющегося платежа';

    final String messageText =
        widget.isVirtualPaymentSelected
            ? 'Вы пытаетесь отметить как выполненный виртуальный платеж из повторяющейся серии.'
            : 'Вы пытаетесь отметить как выполненный повторяющийся платеж.';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(messageText, style: context.text.bodyMedium),
              const SizedBox(height: 12),
              Text(
                'Чтобы отметить его как выполненный, необходимо сначала зафиксировать его, отделив от других повторений.',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildFixationInfoItem(
                context,
                icon: Icons.info_outline,
                text:
                    'Фиксация создаст отдельный платеж, который можно будет отметить как выполненный',
              ),
              const SizedBox(height: 8),
              _buildFixationInfoItem(
                context,
                icon: Icons.calendar_today,
                text: 'Остальные повторения в серии останутся без изменений',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
                if (widget.onFixation != null) {
                  widget.onFixation?.call(); // Вызываем функцию фиксации
                  Navigator.of(context).pop(); // Закрываем нижний лист
                }
              },
              child: const Text('Зафиксировать'),
            ),
          ],
        );
      },
    );
  }

  // Вспомогательный метод для создания элемента в диалоге фиксации
  Widget _buildFixationInfoItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: context.color.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: context.text.bodyMedium)),
      ],
    );
  }

  // Возвращает текстовое описание периода повторения
  String _getRepeatText(DateTimeRepeat repeat) {
    return repeat.displayName;
  }

  // Возвращает текстовое описание периода повторения платежа
  String _getRepeatPeriodText(Payment payment) {
    final dateFormat = DateFormat('d MMM y');
    final startText = payment.dateStart != null ? 'с ${dateFormat.format(payment.dateStart!)}' : '';
    final endText = payment.dateEnd != null ? 'по ${dateFormat.format(payment.dateEnd!)}' : '';

    if (startText.isNotEmpty && endText.isNotEmpty) {
      return '$startText $endText';
    } else if (startText.isNotEmpty) {
      return startText;
    } else if (endText.isNotEmpty) {
      return endText;
    } else {
      return 'Бессрочно';
    }
  }

  Widget _buildCircleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Center(child: Icon(icon, color: color, size: 28)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.text.labelSmall?.copyWith(color: context.color.onSurfaceVariant),
        ),
      ],
    );
  }
}
