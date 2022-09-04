import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/operation_list.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/test.dart';

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
                operations: TestData.testRepeatOperations,
                endPeriod: DateTime(2022, 10, 26),
              ),
            ),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.grey.shade200,
          body: const OperationsList(),
        ),
      ),
    );
  }
}
