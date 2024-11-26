import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        final today = DateTime.now().onlyDate;

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
              GestureDetector(
                onLongPress: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DriftDbViewer(AppDb().db),
                    ),
                  );
                },
                child: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    _updateDialog();
                  },
                ),
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
                  : const SizedBox(),
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
                        onPressed: () => _onTapPayment(payment),
                      );
                    }).toList();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: paymentsWidgets,
                    );
                  },
                  separatorBuilder: (context, index) {
                    if (index == paymentsByDate.length - 1) {
                      return const SizedBox();
                    }

                    final todayPayments = paymentsByDate[index];
                    final nextDayPayments = paymentsByDate[index + 1];

                    return PaymentListSeparator(
                      currentPayment: todayPayments.payments.first,
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

  void _onTapPayment(Payment payment) {
    _updateDialog(payment);
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

  Future<void> _updateDialog([Payment? paymentToEdit]) async {
    Payment? targetPayment;
    if (paymentToEdit != null) {
      targetPayment = paymentToEdit;
      if (targetPayment.isNotParent) {
        final original = await _plannerRepo.getPaymentById(
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
}
