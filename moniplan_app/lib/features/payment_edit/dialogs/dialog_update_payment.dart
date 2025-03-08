// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/payment_edit/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

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

  void save(Payment newPayment, {bool? create}) => context.read<PlannerBloc>().add(
    PlannerEvent.updatePayment(newPayment: newPayment, create: create ?? paymentToEdit == null),
  );

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

  void duplicate() {
    if (paymentToEdit == null || targetPayment == null) {
      return;
    }

    final duplicationPayment = targetPayment.copyWith(
      paymentId: const Uuid().v4(),
      repeat: DateTimeRepeat.noRepeat,
      dateStart: null,
      dateEnd: null,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentEditScreen(
              payment: duplicationPayment,
              onSave: (p) => save(p, create: true),
            ),
      ),
    );
  }

  if (paymentToEdit == null) {
    // Создание нового платежа
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentEditScreen(onSave: (p) => save(p, create: true)),
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
      onDuplicate: duplicate,
      onFixation: targetPayment.isRepeat ? fixate : null,
      onToggleEnabled: (payment) => save(payment),
      onToggleDone: (payment) => save(payment),
      isVirtualPaymentSelected: wasVirtualPaymentSelected,
    );
  }

  // Обновляем бюджет после всех операций
  context.read<PlannerBloc>().add(PlannerEvent.computeBudget());
}
