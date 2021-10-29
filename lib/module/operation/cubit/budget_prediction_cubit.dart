import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';
import 'package:uuid/uuid.dart';

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

  late SplayTreeMap<DateTime, double> _currentPrediction;
  SplayTreeMap<DateTime, double> get prediction => _currentPrediction;

  double? previousPrediction(DateTime date) =>
      _currentPrediction[_currentPrediction.firstKeyAfter(date)];

  void pullOperations() => _prepareOperations(_operationService.getAll());

  void _prepareOperations(List<Operation> data) {
    _operations = data;
    _operationsByDay = _operations.groupBy((e) => e.date.date);
  }

  void predictBudgetByDays() {
    _currentPrediction = _operations.predict();
    emit(PredictionSuccess(
      operations: _operationsByDay,
      predictions: _currentPrediction,
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

class PredictionSuccess extends BudgetPredictionState with EquatableMixin {
  final Map<DateTime, List<Operation>> operations;
  final SplayTreeMap<DateTime, double> predictions;

  PredictionSuccess({
    required this.operations,
    required this.predictions,
  });

  @override
  List<Object?> get props => [Uuid().v4()];
}

class PredictionInProgress extends BudgetPredictionState {}
