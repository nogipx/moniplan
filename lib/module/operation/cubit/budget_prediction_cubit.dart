import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';

class BudgetPredictionCubit extends Cubit<BudgetPredictionState> {
  BudgetPredictionCubit({
    required OperationService operationService,
  })  : _operationService = operationService,
        super(PredictionInitial()) {
    pullOperations();
  }

  final OperationService _operationService;

  late List<Operation> _operations;

  late Map<DateTime, List<Operation>> _operationsByDay;
  Map<DateTime, List<Operation>> get operationsByDay =>
      Map.unmodifiable(_operationsByDay);

  void pullOperations() {
    _prepareOperations(_operationService.getAll());
  }

  void _prepareOperations(List<Operation> data) {
    _operations = data;
    _operationsByDay = _operations.groupBy((e) => e.date.date);
  }

  void predictBudgetByDays() {
    emit(PredictionSuccess(
      operations: _operationsByDay,
      predictions: _operations.predict(),
    ));
  }

  Future<void> saveOperation(Operation data) async {
    await _operationService.save(data);
    _operations.replaceOperation(data);
    final dayOperations = _operationsByDay[data.date.date];
    if (dayOperations != null) {
      dayOperations.replaceOperation(data);
    }
    predictBudgetByDays();
  }

  Future<void> deleteOperation(Operation data) async {
    await _operationService.delete(data);
    _operations.deleteOperation(data);
    final dayOperations = _operationsByDay[data.date.date];
    if (dayOperations != null) {
      dayOperations.deleteOperation(data);
    }
    predictBudgetByDays();
  }
}

abstract class BudgetPredictionState {}

class PredictionInitial extends BudgetPredictionState {}

class PredictionSuccess extends BudgetPredictionState {
  final Map<DateTime, List<Operation>> operations;
  final SplayTreeMap<DateTime, double> predictions;

  PredictionSuccess({
    required this.operations,
    required this.predictions,
  });
}

class PredictionInProgress extends BudgetPredictionState {}
