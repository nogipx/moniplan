import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/operation_list.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'our_budget/_index.dart';

class MoniplanApp extends StatefulWidget {
  const MoniplanApp({Key? key}) : super(key: key);

  @override
  State<MoniplanApp> createState() => _MoniplanAppState();
}

class _MoniplanAppState extends State<MoniplanApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OperationsManagerBloc()
            ..computeBudget(
              OperationsManagerEvent.computeBudget(
                operations: [
                  ...KarimDaryaPeriodicOperations.all,
                  ...KarimDaryaOperationalBudget.all,
                ],
                // startPeriod: DateTime.now(),
                startPeriod: DateTime(2022, 9, 12),
                endPeriod: DateTime(2022, 12, 31),
              ),
            ),
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
              body: const OperationsList(),
            );
          },
        ),
      ),
    );
  }
}
