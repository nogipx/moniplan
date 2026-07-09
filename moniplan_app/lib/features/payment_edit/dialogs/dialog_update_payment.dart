import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/payment_edit/_index.dart';
import 'package:moniplan_app/features/planner/planner_bloc/planner_bloc.dart';
import 'package:moniplan_app/features/planner/planner_bloc/planner_event.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rpc_dart/logger.dart';

final _log = RpcLogger('dialog_update_payment');

Future<void> updateDialog({
  required BuildContext context,
  Payment? paymentToEdit,
}) async {
  Payment? targetPayment;
  if (paymentToEdit != null) {
    targetPayment = paymentToEdit;
    if (targetPayment.isNotParent) {
      final blocState = context.read<PlannerBloc>().state;
      final payments = blocState.getPayments;
      final originalId = targetPayment.originalPaymentId;
      if (originalId != null) {
        final original = payments.firstWhere(
          (p) => p.paymentId == originalId,
          orElse: () => targetPayment!,
        );
        targetPayment = original;
      }
    }
  }

  final suggestedTags = <String>{
    for (final p in context.read<PlannerBloc>().state.getPayments)
      ...p.details.tags.where((t) => t.trim().isNotEmpty && !t.contains(':')),
  };

  Future<bool> save(Payment newPayment, {bool? create}) async {
    try {
      // Проверяем, что платеж валиден
      if (newPayment.details.money <= 0) {
        showToast('Сумма платежа должна быть больше нуля');
        return false;
      }

      // Отправляем событие обновления платежа в блок планировщика и не ждём ответа от БД
      context.read<PlannerBloc>().add(
        PlannerEvent.updatePayment(
          newPayment: newPayment,
          create: create ?? paymentToEdit == null,
        ),
      );

      // Считаем операцию успешной сразу после отправки события
      return true;
    } on Object catch (e) {
      _log.error('Ошибка при сохранении платежа: $e');
      showToast('Ошибка при сохранении платежа');
      return false;
    }
  }

  void delete() {
    if (paymentToEdit == null) {
      return;
    }

    showDeletePaymentDialog(context, () {
      if (targetPayment == null) {
        return;
      }

      context.read<PlannerBloc>().add(
        PlannerEvent.deletePayment(paymentId: targetPayment.paymentId),
      );
    }, payment: targetPayment);
  }

  void fixate() {
    if (paymentToEdit == null || targetPayment == null) {
      return;
    }

    context.read<PlannerBloc>().add(
      PlannerEvent.fixateRepeatedPayment(paymentId: targetPayment.paymentId),
    );
  }

  Future<DateTime?> selectDate(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      // Отбрасываем время у даты
      return picked.dayBound;
    }
    return null;
  }

  void move() {
    if (paymentToEdit == null || targetPayment == null) {
      return;
    }

    selectDate(context, targetPayment.date).then((selectedDate) {
      if (selectedDate != null) {
        final updatedPayment = targetPayment?.copyWith(date: selectedDate);
        if (updatedPayment != null) {
          save(updatedPayment);
          showToast(
            'Платёж перенесен на ${DateFormat('d MMMM y').format(selectedDate)}',
          );
        }
      }
    });
  }

  if (paymentToEdit == null) {
    // Создание нового платежа
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentEditScreen(
          suggestedTags: suggestedTags,
          onSave: (p) async {
            final success = await save(p, create: true);
            if (!success && context.mounted) {
              showToast('Не удалось сохранить платеж');
            }
          },
        ),
      ),
    );
  } else {
    // Проверяем, был ли изначально выбран виртуальный платеж
    final wasVirtualPaymentSelected = paymentToEdit.isNotParent;

    // Просмотр существующего платежа
    await PaymentActionsBottomSheet.show(
      context: context,
      payment: targetPayment!,
      onDelete: delete,
      onMove: move,
      onFixation: targetPayment.isRepeat ? fixate : null,
      onToggleEnabled: save,
      onToggleDone: save,
      isVirtualPaymentSelected: wasVirtualPaymentSelected,
    );
  }

  // Обновляем бюджет после всех операций
  context.read<PlannerBloc>().add(const PlannerEvent.computeBudget());
}
