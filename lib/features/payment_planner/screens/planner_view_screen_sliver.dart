import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/features/_common/_index.dart';
import 'package:moniplan/features/payment_planner/_index.dart';
import 'package:moniplan/features/payment_planner/dialogs/_index.dart';
import 'package:moniplan/features/payment_planner/screens/planner_charts_screen.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:sticky_headers/sticky_headers.dart';
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

        final titleWidget = Text(
          '$dateStartString - $dateEndString',
          style: context.text.displaySmall,
        );

        final today = DateTime.now().dayBound;
        final paymentsByDate = state.getPaymentsByDate;
        final paymentsByDateIndexed = paymentsByDate.indexed.toList();

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
            ? ColoredBox(
                child: MoneyFlowWidget(state: state.moneyFlow),
                color: context.color.surface,
              )
            : const SizedBox.shrink();

        Widget getSliverList(int originalIndex, PaymentsDateGrouped group) {
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
        }

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
                            sliver: SuperSliverList(
                              listController: _listController,
                              // delegate: SliverChildListDelegate(composedSliversList),
                              delegate: SliverChildBuilderDelegate(
                                childCount: paymentsByDateIndexed.length,
                                (context, index) {
                                  final item = paymentsByDateIndexed[index];
                                  return getSliverList(item.$1, item.$2);
                                },
                              ),
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
                          context.color.surface.withOpacity(.7),
                          context.color.surface.withOpacity(0),
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

// Класс для кастомного Sticky Header
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 110;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
