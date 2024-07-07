import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/features/_common/db_view_floating_button.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:moniplan/features/payment_planner/_index.dart';

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
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        final dateStartRaw = state.mapOrNull(
          budgetComputed: (s) => s.dateStart,
        );
        final dateStartString = dateStartRaw != null
            ? DateFormat(DateFormat.ABBR_MONTH_DAY, 'ru').format(dateStartRaw)
            : '';

        final dateEndRaw = state.mapOrNull(
          budgetComputed: (s) => s.dateEnd,
        );
        final dateEndString = dateEndRaw != null
            ? DateFormat(DateFormat.ABBR_MONTH_DAY, 'ru').format(dateEndRaw)
            : '';

        final titleWidget = Text('$dateStartString - $dateEndString');

        return MoniplanThemeListenable(
          child: Scaffold(
            floatingActionButton: dbInspectorFloatingActionButton,
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
            body: BlocBuilder<PlannerBloc, PlannerState>(
              builder: (context, state) {
                return MoniplanThemeListenable(
                  child: CustomScrollView(
                    controller: _controller,
                    slivers: [
                      SliverPinnedHeader(
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
                            context.read<PlannerBloc>().add(
                                  PlannerEvent.updatePayment(
                                    newPayment: payment.copyWith(
                                      isDone: !payment.isDone,
                                      // isEnabled: !payment.isEnabled,
                                    ),
                                  ),
                                );
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
