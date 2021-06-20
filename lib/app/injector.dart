import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:moniplan/bloc/budget_prediction_bloc.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:moniplan/service/budget_event_service_hive.dart';

class Injector extends StatefulWidget {
  final Widget child;
  final Box<Operation> operationHive;

  const Injector({
    Key? key,
    required this.child,
    required this.operationHive,
  }) : super(key: key);

  @override
  _InjectorState createState() => _InjectorState();
}

class _InjectorState extends State<Injector> {
  late final OperationService operationService;

  @override
  void initState() {
    operationService = OperationServiceHive(hive: widget.operationHive);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<OperationService>.value(value: operationService)
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BudgetPredictionBloc>(
            create: (BuildContext context) {
              return BudgetPredictionBloc()..compute(operationService.getAll());
            },
          )
        ],
        child: widget.child,
      ),
    );
  }
}
