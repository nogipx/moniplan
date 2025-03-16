// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/payment_edit/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:async';
import 'package:intl/intl.dart';

Future<void> updateDialog({
  required BuildContext context,
  required IPlannerRepo plannerRepo,
  Payment? paymentToEdit,
}) async {
  Payment? targetPayment;
  if (paymentToEdit != null) {
    targetPayment = paymentToEdit;
    if (targetPayment.isNotParent) {
      final original = await plannerRepo.getPaymentById(
        plannerId: targetPayment.plannerId,
        paymentId: targetPayment.originalPaymentId ?? '',
      );
      if (original != null) {
        targetPayment = original;
      }
    }
  }

  Future<bool> save(Payment newPayment, {bool? create}) async {
    try {
      // Проверяем, что платеж валиден
      if (newPayment.details.money <= 0) {
        showToast('Сумма платежа должна быть больше нуля');
        return false;
      }

      // Создаем Completer для ожидания результата операции
      final completer = Completer<bool>();

      // Сохраняем ссылку на PlannerBloc перед открытием нового экрана
      final plannerBloc = context.read<PlannerBloc>();

      // Подписываемся на состояние блока планировщика
      late final StreamSubscription<PlannerState> subscription;
      subscription = plannerBloc.stream.listen((state) {
        // Если в состоянии есть ошибки, считаем операцию неуспешной
        if (state.errors.isNotEmpty) {
          subscription.cancel();
          completer.complete(false);
          return;
        }

        // Проверяем, содержит ли состояние наш платеж
        if (state is PlannerBudgetComputedState) {
          final paymentExists = state.payments.any((p) => p.paymentId == newPayment.paymentId);
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
      plannerBloc.add(
        PlannerEvent.updatePayment(newPayment: newPayment, create: create ?? paymentToEdit == null),
      );

      // Ждем результат операции
      return await completer.future;
    } catch (e) {
      print('Ошибка при сохранении платежа: $e');
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

  Future<DateTime?> selectDate(BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
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
          showToast('Платёж перенесен на ${DateFormat('d MMMM y').format(selectedDate)}');
        }
      }
    });
  }

  if (paymentToEdit == null) {
    // Создание нового платежа
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentEditScreen(
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
      onToggleEnabled: (payment) => save(payment),
      onToggleDone: (payment) => save(payment),
      isVirtualPaymentSelected: wasVirtualPaymentSelected,
    );
  }

  // Обновляем бюджет после всех операций
  context.read<PlannerBloc>().add(PlannerEvent.computeBudget());
}
