import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan/widgets/operation/money_flow_widget.dart';
import 'package:moniplan/widgets/operation/_index.dart';
import 'package:moniplan/widgets/statistics/statistic_chart.dart';
import 'package:moniplan_core/moniplan_core.dart';

class MoniplanApp extends StatefulWidget {
  const MoniplanApp({super.key});

  @override
  State<MoniplanApp> createState() => _MoniplanAppState();
}

class _MoniplanAppState extends State<MoniplanApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OperationsManagerBloc()..computeBudget(currentRequest),
        ),
      ],
      child: MaterialApp(
        home: BlocBuilder<OperationsManagerBloc, OperationsManagerState>(
          builder: (context, state) {
            final dateStartRaw = state.mapOrNull(
              budgetComputed: (s) => s.dateStart,
            );
            final dateStartString = dateStartRaw != null
                ? DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY, 'ru')
                    .format(dateStartRaw)
                : '';

            final dateEndRaw = state.mapOrNull(
              budgetComputed: (s) => s.dateEnd,
            );
            final dateEndString = dateEndRaw != null
                ? DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY, 'ru')
                    .format(dateEndRaw)
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
                                      budget: state.budget.unlock,
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
              backgroundColor: Colors.grey.shade200,
              body: StreamBuilder<OperationsManagerState>(
                stream: context.read<OperationsManagerBloc>().stream,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: snapshot.data!.maybeMap(
                            budgetComputed: (s) => MoneyFlowWidget(
                              state: s.moneyFlow,
                            ),
                            orElse: () => const SizedBox(),
                          ),
                        ),
                        SliverList(
                          delegate: OperationsListSliver(
                            operations: snapshot.data!.operationsGenerated,
                            budget: snapshot.data!.budget,
                          ),
                        )
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
