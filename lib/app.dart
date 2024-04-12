import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan/widgets/operation/money_flow_widget.dart';
import 'package:moniplan/widgets/operation/_index.dart';
import 'package:moniplan/widgets/statistics/statistic_chart.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoniplanApp extends StatefulWidget {
  const MoniplanApp({
    super.key,
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

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
          create: (_) => PaymentsManagerBloc()..computeBudget(currentRequest),
        ),
      ],
      child: ThemeChanger(
        storage: ThemeChangerStorageSharedPreferences(
          sharedPreferences: widget.sharedPreferences,
        ),
        onChangeTheme: (brightness) {
          MoniplanColors.brightness = brightness;
        },
        builder: (context) {
          return MaterialApp(
            home: BlocBuilder<PaymentsManagerBloc, PaymentsManagerState>(
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

                return MoniplanThemeListenable(
                  child: Scaffold(
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
                    backgroundColor: MoniplanColors.white,
                    body: BlocBuilder<PaymentsManagerBloc, PaymentsManagerState>(
                      builder: (context, state) {
                        return CustomScrollView(
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
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
