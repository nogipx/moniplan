import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:moniplan/features/payment_planner/widgets/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

typedef OnPaymentPressed = void Function(Payment payment);
typedef _PaymentWidgetBuilder = Widget Function(BuildContext context, Payment payment);

class PaymentsListSliver extends SliverChildBuilderDelegate {
  final List<Payment> payments;
  final Map<Payment, num> budget;
  final OnPaymentPressed? onPaymentPressed;
  final DateTime today;
  final bool debugColors;

  PaymentsListSliver({
    required this.payments,
    required this.budget,
    required this.today,
    this.onPaymentPressed,
    this.debugColors = false,
  }) : super(
          (context, index) {
            final int itemIndex = index ~/ 2;
            Widget widget;

            if (index.isEven) {
              final payment = payments[itemIndex];

              widget = _itemBuilder(budget, onPaymentPressed).call(context, payment);

              if (index == 0) {
                widget = Column(
                  children: [
                    PaymentListDaySeparator(
                      date: payment.date,
                      today: today,
                    ),
                    widget,
                  ],
                );
              }

              widget = widget;
            } else {
              widget = _separatorBuilder(payments, today).call(context, itemIndex);
            }
            return widget;
          },
          semanticIndexCallback: (widget, localIndex) {
            if (localIndex.isEven) {
              return localIndex ~/ 2;
            }
            return null;
          },
          childCount: math.max(0, payments.length * 2 - 1),
        );

  static _PaymentWidgetBuilder _itemBuilder(
    Map<Payment, num> budget,
    OnPaymentPressed? onPressed,
  ) {
    return (context, operation) {
      return PaymentListItem(
        payment: operation,
        mediateSummary: budget[operation],
        onPressed: () => onPressed?.call(operation),
      );
    };
  }

  static IndexedWidgetBuilder _separatorBuilder(
    List<Payment> operations,
    DateTime today,
  ) {
    return (context, index) {
      return PaymentListSeparator(
        previousPayment: operations[index],
        nextPayment: operations[index + 1],
        today: today,
      );
    };
  }
}
