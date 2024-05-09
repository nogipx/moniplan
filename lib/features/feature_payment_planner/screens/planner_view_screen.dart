import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/main.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';

class PlannerViewScreen extends StatefulWidget {
  const PlannerViewScreen({super.key});

  @override
  State<PlannerViewScreen> createState() => _PlannerViewScreenState();
}

class _PlannerViewScreenState extends State<PlannerViewScreen> {
  late final ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MoniplanThemeListenable(
      child: BlocBuilder<PaymentsManagerBloc, PaymentsManagerState>(
        builder: (context, state) {
          final dateStartRaw = state.mapOrNull(
            budgetComputed: (s) => s.dateStart,
          );
          final dateStartString = dateStartRaw != null
              ? DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY, 'ru').format(dateStartRaw)
              : '';

          final dateEndRaw = state.mapOrNull(
            budgetComputed: (s) => s.dateEnd,
          );
          final dateEndString = dateEndRaw != null
              ? DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY, 'ru').format(dateEndRaw)
              : '';

          final titleWidget = Text('$dateStartString - $dateEndString');

          return Scaffold(
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
            backgroundColor: MoniplanColors.white,
            body: BlocBuilder<PaymentsManagerBloc, PaymentsManagerState>(
              builder: (context, state) {
                return CustomScrollView(
                  controller: _controller,
                  slivers: [
                    SliverToBoxAdapter(
                      child: state.maybeMap(
                        budgetComputed: (s) => MoneyFlowWidget(
                          state: s.moneyFlow,
                        ),
                        orElse: () => const SizedBox(),
                      ),
                    ),
                    SliverList(
                      delegate: PaymentsListSliver(
                        operations: state.paymentsGenerated,
                        budget: state.budget,
                        onPaymentPressed: (payment) async {
                          final repo = PaymentsRepo(store: objectbox.store);
                          await repo.setDoneState(
                            plannerId: '',
                            paymentId: payment.paymentId,
                            isDone: !payment.isDone,
                          );
                          context.read<PaymentsManagerBloc>().reload();
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
