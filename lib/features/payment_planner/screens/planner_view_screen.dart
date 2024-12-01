import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/features/_common/_index.dart';
import 'package:moniplan/features/payment_planner/_index.dart';
import 'package:moniplan/features/payment_planner/dialogs/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlannerViewScreen extends StatefulWidget {
  const PlannerViewScreen({super.key});

  @override
  State<PlannerViewScreen> createState() => _PlannerViewScreenState();
}

class _PlannerViewScreenState extends State<PlannerViewScreen> {
  late final IPlannerRepo _plannerRepo;
  late final ItemScrollController _controller;
  bool _isFirstScrolled = false;

  @override
  void initState() {
    _plannerRepo = PlannerRepoDrift(db: AppDb());
    _controller = ItemScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlannerBloc, PlannerState>(
      listener: (context, state) {
        if (state is PlannerBudgetComputedState &&
            state.getPaymentsByDate.isNotEmpty &&
            !_isFirstScrolled) {
          setState(() {
            _isFirstScrolled = true;
          });
          _moveToDate(DateTime.now(), jump: true);
        }
      },
      builder: (context, state) {
        final dateStartRaw = state.mapOrNull(
          budgetComputed: (s) => s.dateStart,
        );
        final dateStartString =
            dateStartRaw != null ? DateFormat(plannerBoundDateFormat).format(dateStartRaw) : '';

        final dateEndRaw = state.mapOrNull(
          budgetComputed: (s) => s.dateEnd,
        );
        final dateEndString =
            dateEndRaw != null ? DateFormat(plannerBoundDateFormat).format(dateEndRaw) : '';

        final titleWidget = Text('$dateStartString - $dateEndString');

        final paymentsByDate = state.getPaymentsByDate;
        final today = DateTime.now().dayBound;

        return Scaffold(
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: ElevatedButton(
                  child: Text('Сегодня'),
                  onPressed: () {
                    _moveToDate(DateTime.now());
                  },
                ),
              ),
              ExtendedAppFloatingButton(
                onPressed: () {
                  updateDialog(
                    context: context,
                    plannerRepo: _plannerRepo,
                  );
                },
              ),
            ],
          ),
          appBar: AppBar(
            title: titleWidget,
            actions: [
              IconButton(
                icon: const Icon(Icons.ssid_chart),
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) {
                        return Scaffold(
                          body: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 24,
                              ),
                              child: Center(
                                child: StatisticChart(
                                  budget: state.budget,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              state is PlannerBudgetComputedState
                  ? MoneyFlowWidget(state: state.moneyFlow)
                  : const SizedBox.shrink(),
              Expanded(
                child: ScrollablePositionedList.separated(
                  itemScrollController: _controller,
                  itemCount: paymentsByDate.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    if (index < 0) {
                      return const SizedBox();
                    }

                    final datePayments = paymentsByDate[index];

                    var paymentsWidgets = datePayments.payments.map((payment) {
                      return PaymentListItem(
                        payment: payment,
                        mediateSummary: state.budget[payment],
                        onPressed: () => updateDialog(
                          context: context,
                          paymentToEdit: payment,
                          plannerRepo: _plannerRepo,
                        ),
                      );
                    }).toList();

                    // пусть следующий и предыдущий платежи буду необязательные
                    // учти этот момент тоже.
                    // считай что если нет currentPayment

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (index == 0)
                          PaymentListSeparator(
                            nextPayment: datePayments.payments.firstOrNull,
                            today: today,
                          ),
                        ...paymentsWidgets,
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    if (index == paymentsByDate.length - 1) {
                      return const SizedBox();
                    }

                    final todayPayments = paymentsByDate[index];
                    final nextDayPayments = paymentsByDate[index + 1];

                    return PaymentListSeparator(
                      previousPayment: todayPayments.payments.first,
                      nextPayment: nextDayPayments.payments.first,
                      today: today,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _moveToDate(DateTime date, {bool jump = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final state = context.read<PlannerBloc>().state.getPaymentsByDate.getIndexOfDate(date);
    if (state == null || !_controller.isAttached) {
      return;
    }

    if (jump) {
      _controller.jumpTo(
        index: state.index,
        alignment: state.alignment,
      );
    } else {
      _controller.scrollTo(
        index: state.index,
        alignment: state.alignment,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    }
  }
}
