// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/features/planner/_index.dart';
import 'package:moniplan_app/features/planner/screens/payments_sliver_list.dart';
import 'package:moniplan_app/features/planner_statistics/ui/planner_statistics_screen.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class PlannerViewScreenSliver extends StatefulWidget {
  const PlannerViewScreenSliver({super.key});

  @override
  State<PlannerViewScreenSliver> createState() => _PlannerViewScreenSliverState();
}

class _PlannerViewScreenSliverState extends State<PlannerViewScreenSliver> {
  final _listController = ListController();
  final _scrollController = ScrollController();

  bool _isFirstScrolled = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlannerBloc, PlannerState>(
      listener: (context, state) {
        if (state is PlannerBudgetComputedState && state.getPaymentsByDate.isNotEmpty && !_isFirstScrolled) {
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
        final dateStartString = dateStartRaw != null ? DateFormat(plannerBoundDateFormat).format(dateStartRaw) : '';

        final dateEndRaw = state.mapOrNull(
          budgetComputed: (s) => s.dateEnd,
        );
        final dateEndString = dateEndRaw != null ? DateFormat(plannerBoundDateFormat).format(dateEndRaw) : '';

        final titleWidget = Text(
          '$dateStartString - $dateEndString',
          style: context.text.displaySmall,
        );

        final today = DateTime.now().dayBound;
        final paymentsByDate = state.getPaymentsByDate;

        final appBar = AppBar(
          title: titleWidget,
          actions: [
            IconButton(
              icon: const Icon(Icons.ssid_chart),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => PlannerStatisticsScreen(
                      plannerId: state.plannerId,
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
                  plannerRepo: AppDi.instance.getPlannerRepo(),
                );
              },
            ),
          ],
        );

        final moneyFlow = state is PlannerBudgetComputedState
            ? ColoredBox(
                child: MoneyFlowWidget(state: state.moneyFlow),
                color: context.color.surface,
              )
            : const SizedBox.shrink();

        return Scaffold(
          floatingActionButton: fab,
          appBar: appBar,
          body: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    moneyFlow,
                    Expanded(
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpace.s100,
                            ),
                            sliver: PaymentsSliverList(
                              listController: _listController,
                              today: today,
                              budget: state.budget,
                              paymentsByDate: paymentsByDate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.color.surface,
                          context.color.surface.withValues(alpha: .7),
                          context.color.surface.withValues(alpha: 0),
                        ],
                        stops: [0, .8, 1],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                    ),
                  ),
                ),
              )
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
