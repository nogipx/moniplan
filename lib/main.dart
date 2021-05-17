import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moniplan/bloc/budget_prediction_bloc.dart';
import 'package:moniplan/hive/domain_adapter.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/service/budget_event_service_hive.dart';
import 'package:moniplan/widget/budget/budget_schedule_widget.dart';
import 'package:moniplan/widget/budget/operation_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(OperationAdapter());

  final operationBox = await Hive.openBox<Operation>(OperationService.key);

  final operationService = OperationServiceHive(hive: operationBox);
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<OperationService>.value(value: operationService)
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BudgetPredictionBloc>(
            create: (BuildContext context) =>
                BudgetPredictionBloc(eventService: operationService)..compute(),
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
  late final OperationService operationService;

  @override
  void initState() {
    operationService = context.read<OperationService>();
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
        onPressed: () async {
          await OperationWidget.showEdit(
            context: context,
          ).then((value) {
            setState(() {
              if (value != null) {
                context.read<OperationService>().save(value);
                context.read<BudgetPredictionBloc>().compute();
              }
            });
          });
        },
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Operation>(OperationService.key).listenable(),
        builder: (context, box, widget) {
          final operations = operationService.getAll();
          return BudgetScheduleWidget(
            eventsByDay: predictionBloc.predictBudget(operations),
          );
        },
      ),
    );
  }
}
