import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/widgets/operation/money_flow_widget.dart';
import 'package:moniplan/widgets/operation/operation_list.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'our_budget/budget_requests.dart';

class MoniplanApp extends StatefulWidget {
  const MoniplanApp({Key? key}) : super(key: key);

  @override
  State<MoniplanApp> createState() => _MoniplanAppState();
}

class _MoniplanAppState extends State<MoniplanApp> {
  @override
  void initState() {
    super.initState();
    // final json = jsonEncode(onlyRequiredSpendsToYearEnd.toJson());
    // final t = json.toString();
    // final fromJson = OperationsManagerEvent.fromJson(jsonDecode(json));

    // print(onlyRequiredSpendsToYearEnd == fromJson);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OperationsManagerBloc()
            ..computeBudget(BudgetsRequests.currentSpends),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', ''),
        ],
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
