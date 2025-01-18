// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/features/planner/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class PaymentsSliverList extends StatelessWidget {
  final ListController listController;
  final DateTime today;
  final Map<Payment, num> budget;
  final List<PaymentsDateGrouped> paymentsByDate;

  const PaymentsSliverList({
    super.key,
    required this.listController,
    required this.paymentsByDate,
    required this.today,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    return SuperSliverList(
      listController: listController,
      delegate: SliverChildBuilderDelegate(
        childCount: paymentsByDate.length,
        (context, index) {
          final item = paymentsByDate[index];
          return _getSliverItem(context, index, item);
        },
      ),
    );
  }

  Widget _getSliverItem(BuildContext context, int originalIndex, PaymentsDateGrouped group) {
    final neighbours = paymentsByDate.getNeighbours(originalIndex);
    final isMonthEdge = group.date.isMonthEdge(
      prevDate: neighbours?.before?.date,
      nextDate: neighbours?.after?.date,
    );

    return StickyHeaderBuilder(
      builder: (BuildContext context, double stuckAmount) {
        final normalizedAnimation = normalizeToRange(stuckAmount, -1, 1, 0, 1);

        return PaymentListSeparator(
          currDate: group.date,
          isMonthEdge: isMonthEdge,
          today: today,
          payments: group.payments,
          animationValue: normalizedAnimation,
          stuckAmount: stuckAmount,
        );
      },
      content: Column(
        children: group.payments.map((e) {
          final payment = e;
          return PaymentListItem(
            payment: payment,
            mediateSummary: budget[payment],
            onPressed: () => updateDialog(
              context: context,
              paymentToEdit: payment,
              plannerRepo: AppDi.instance.getPlannerRepo(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
