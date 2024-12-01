import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/features/payment_planner/dialogs/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

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
        PlannerEvent.updatePayment(
          newPayment: newPayment,
          create: create ?? paymentToEdit == null,
        ),
      );

  void delete() {
    if (paymentToEdit == null) {
      return;
    }

    showDeletePaymentDialog(
      context,
      () {
        if (targetPayment == null) {
          return;
        }

        context.read<PlannerBloc>().add(
              PlannerEvent.deletePayment(
                paymentId: targetPayment.paymentId,
              ),
            );
      },
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

    showUpdatePaymentDialog(
      context: context,
      targetPayment: duplicationPayment,
      onSave: (p) => save(p, create: true),
    );
  }

  void fixate() {
    if (paymentToEdit == null || targetPayment == null) {
      return;
    }

    context.read<PlannerBloc>().add(
          PlannerEvent.fixateRepeatedPayment(
            paymentId: targetPayment.paymentId,
          ),
        );
  }

  showUpdatePaymentDialog(
    context: context,
    paymentWhichTapped: paymentToEdit,
    targetPayment: targetPayment,
    onSave: save,
    onDelete: delete,
    onDuplicate: duplicate,
    onFixation: fixate,
  ).then((_) {
    context.read<PlannerBloc>().add(PlannerEvent.computeBudget());
  });
}
