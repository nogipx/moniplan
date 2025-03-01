// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/features/planner/_index.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
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
      delegate: SliverChildBuilderDelegate(childCount: paymentsByDate.length, (context, index) {
        final item = paymentsByDate[index];
        return _getSliverItem(context, index, item);
      }),
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
      content: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            group.payments.isEmpty
                ? const SizedBox(height: 8) // Если платежей нет, просто добавляем небольшой отступ
                : Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildPaymentsList(context, group.payments),
                ),
      ),
    );
  }

  Widget _buildPaymentsList(BuildContext context, List<Payment> payments) {
    // Сортируем платежи: сначала активные, потом неактивные и выполненные
    final sortedPayments = [...payments]..sort((a, b) {
      // Сначала сортируем по статусу (активные в начале)
      if (a.isEnabled && !a.isDone && (!b.isEnabled || b.isDone)) return -1;
      if ((!a.isEnabled || a.isDone) && b.isEnabled && !b.isDone) return 1;

      // Затем сортируем по типу (доходы в начале)
      if (a.type == PaymentType.income && b.type == PaymentType.expense) return -1;
      if (a.type == PaymentType.expense && b.type == PaymentType.income) return 1;

      // Наконец, сортируем по сумме (по убыванию)
      return b.normalizedMoney.abs().compareTo(a.normalizedMoney.abs());
    });

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: sortedPayments.length,
      itemBuilder: (context, index) {
        final payment = sortedPayments[index];

        // Добавляем анимацию появления для каждого элемента
        return AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeInOut,
          child: PaymentListItem(
            payment: payment,
            mediateSummary: budget[payment],
            onPressed:
                () => updateDialog(
                  context: context,
                  paymentToEdit: payment,
                  plannerRepo: AppDi.instance.getPlannerRepo(),
                ),
          ),
        );
      },
    );
  }
}
