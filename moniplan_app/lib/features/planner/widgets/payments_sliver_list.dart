import 'package:flutter/material.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/payment/usecases/sort_payments_usecase.dart';
import 'package:moniplan_app/features/payment_edit/_index.dart';
import 'package:moniplan_app/features/planner/widgets/payment_list_item.dart';
import 'package:moniplan_app/features/planner/widgets/separators/payment_list_separator.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class PaymentsSliverList extends StatelessWidget {
  final ListController listController;
  final DateTime today;
  final Map<Payment, num> budget;
  final List<PaymentsDateGrouped> paymentsByDate;

  const PaymentsSliverList({
    required this.listController,
    required this.paymentsByDate,
    required this.today,
    required this.budget,
    super.key,
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

    // Если это начало месяца, показываем разделитель месяца отдельно (не sticky)
    if (isMonthEdge) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Разделитель месяца (не sticky)
          PaymentListSeparator(
            currDate: group.date,
            isMonthEdge: true,
            today: today,
            payments: group.payments,
            showDaySeparator: false, // Не показываем разделитель дня в месячном разделителе
          ),

          // Разделитель дня (sticky)
          StickyHeaderBuilder(
            builder: (BuildContext context, double stuckAmount) {
              final normalizedAnimation = normalizeToRange(stuckAmount, -1, 1, 0, 1);

              return PaymentListSeparator(
                currDate: group.date,
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
                      ? const SizedBox(height: 8)
                      : Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildPaymentsList(group.payments),
                      ),
            ),
          ),
        ],
      );
    } else {
      // Обычный день (не начало месяца) - показываем только разделитель дня (sticky)
      return StickyHeaderBuilder(
        builder: (BuildContext context, double stuckAmount) {
          final normalizedAnimation = normalizeToRange(stuckAmount, -1, 1, 0, 1);

          return PaymentListSeparator(
            currDate: group.date,
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
                  ? const SizedBox(height: 8)
                  : Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildPaymentsList(group.payments),
                  ),
        ),
      );
    }
  }

  Widget _buildPaymentsList(List<Payment> payments) {
    // Используем юзкейс для сортировки платежей
    final sortedPayments = SortPaymentsUsecase(payments: payments.toList()).run();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: sortedPayments.length,
      itemBuilder: (context, index) {
        final payment = sortedPayments[index];

        // Добавляем анимацию появления для каждого элемента
        return AnimatedOpacity(
          opacity: 1,
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
