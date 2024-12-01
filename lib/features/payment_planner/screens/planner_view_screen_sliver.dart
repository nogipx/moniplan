import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/features/_common/_index.dart';
import 'package:moniplan/features/payment_planner/_index.dart';
import 'package:moniplan/features/payment_planner/dialogs/_index.dart';
import 'package:moniplan/features/payment_planner/screens/planner_charts_screen.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class PlannerViewScreenSliver extends StatefulWidget {
  const PlannerViewScreenSliver({super.key});

  @override
  State<PlannerViewScreenSliver> createState() => _PlannerViewScreenSliverState();
}

class _PlannerViewScreenSliverState extends State<PlannerViewScreenSliver> {
  late final IPlannerRepo _plannerRepo;
  final _listController = ListController();
  final _scrollController = ScrollController();

  bool _isFirstScrolled = false;

  @override
  void initState() {
    _plannerRepo = PlannerRepoDrift(db: AppDb());
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

        final today = DateTime.now().dayBound;
        final paymentsByDate = state.getPaymentsByDate;

        final sliverList = SuperSliverList.builder(
          listController: _listController,
          itemCount: paymentsByDate.length,
          itemBuilder: (context, index) {
            final datePayments = paymentsByDate[index];
            final neighbours = paymentsByDate.getNeighbours(index);

            return PaymentListSeparator(
              datePayments: datePayments,
              prevDate: neighbours?.before?.date,
              nextDate: neighbours?.after?.date,
              today: today,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: datePayments.payments.map((payment) {
                  return PaymentListItem(
                    payment: payment,
                    mediateSummary: state.budget[payment],
                    onPressed: () => updateDialog(
                      context: context,
                      paymentToEdit: payment,
                      plannerRepo: _plannerRepo,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );

        final appBar = AppBar(
          title: titleWidget,
          actions: [
            IconButton(
              icon: const Icon(Icons.ssid_chart),
              onPressed: () {
                final bloc = context.read<PlannerBloc>();
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: bloc,
                      child: PlannerChartsScreen(),
                    ),
                  ),
                );
              },
            ),
          ],
        );

        final fab = Row(
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
        );

        final moneyFlow = state is PlannerBudgetComputedState
            ? MoneyFlowWidget(state: state.moneyFlow)
            : const SizedBox.shrink();

        return Scaffold(
          floatingActionButton: fab,
          appBar: appBar,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(
                  bottom: AppSpace.s100,
                ),
                sliver: sliverList,
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
    if (state == null || !_listController.isAttached) {
      return;
    }

    if (jump) {
      _listController.jumpToItem(
        index: state.index,
        alignment: state.alignment,
        scrollController: _scrollController,
      );
    } else {
      _listController.animateToItem(
        index: state.index,
        alignment: state.alignment,
        scrollController: _scrollController,
        duration: (estimatedDistance) => Duration(milliseconds: 250),
        curve: (estimatedDistance) => Curves.fastLinearToSlowEaseIn,
      );
    }
  }
}
