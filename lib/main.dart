import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:planimon/bloc/budget_prediction_bloc.dart';
import 'package:planimon/hive/domain_adapter.dart';
import 'package:planimon/sdk/domain.dart';
import 'package:planimon/sdk/service/record_service.dart';
import 'package:planimon/service/budget_event_service_hive.dart';
import 'package:dartx/dartx.dart';
import 'package:planimon/widget/budget_schedule_widget.dart';
import 'package:planimon/widget/event_edit_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BudgetEventAdapter());

  final budgetEventBox =
      await Hive.openBox<BudgetEvent>(BudgetEventService.boxName);

  final budgetEventService = BudgetEventServiceHive(hive: budgetEventBox);
  // budgetEventBox.clear();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BudgetEventService>.value(value: budgetEventService)
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BudgetPredictionBloc>(
            create: (BuildContext context) =>
                BudgetPredictionBloc(eventService: budgetEventService)
                  ..compute(),
          )
        ],
        child: ExampleApp(),
      ),
    ),
  );
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late final BudgetPredictionBloc predictionBloc;
  late final BudgetEventService budgetEventService;

  @override
  void initState() {
    budgetEventService = context.read<BudgetEventService>();
    predictionBloc = context.read<BudgetPredictionBloc>();
    super.initState();
  }

  @override
  void dispose() {
    predictionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moniplan'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          BudgetEventEditPage.showEditModal(context: context);
        },
      ),
      body: ValueListenableBuilder<Box<BudgetEvent>>(
        valueListenable:
            Hive.box<BudgetEvent>(BudgetEventService.boxName).listenable(),
        builder: (context, box, widget) {
          final days = budgetEventService.getEventsByDays();
          return BudgetScheduleWidget(eventsByDay: days);
        },
      ),
    );
  }
}
