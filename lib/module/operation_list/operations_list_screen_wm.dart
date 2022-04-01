import 'dart:collection';

import 'package:dartx/dartx.dart';
import 'package:elementary/elementary.dart';
import 'package:moniplan/module/operation_list/export.dart';
import 'package:moniplan/module/operation_list/widgets/operation_list_item.dart';
import 'package:moniplan/sdk/domain.dart';

class OperationsComputeResult {
  final List<Operation> operations;
  final Map<DateTime, List<Operation>> operationsByDay;
  final SplayTreeMap<DateTime, double> prediction;

  OperationsComputeResult(
    this.operations,
    this.operationsByDay,
    this.prediction,
  );
}

class OperationsListScreenWM
    extends WidgetModel<OperationListScreen, OperationsListScreenModel> {
  final EntityStateNotifier<OperationsComputeResult> _result =
      EntityStateNotifier();
  final OperationService _operationService;

  ListenableState<EntityState<OperationsComputeResult>> get result => _result;

  late List<Operation> _operations;
  late Map<DateTime, List<Operation>> _operationsByDay;
  late SplayTreeMap<DateTime, double> _currentPrediction;

  OperationsListScreenWM(
    OperationsListScreenModel model,
    this._operationService,
  ) : super(model);

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    pullOperations();
  }

  double? previousPrediction(DateTime date) {
    return _currentPrediction[_currentPrediction.firstKeyAfter(date)];
  }

  void pullOperations() => _prepareOperations(_operationService.getAll());

  void predictBudgetByDays() {
    _currentPrediction = _operations.predict();
    _result.content(OperationsComputeResult(
      _operations,
      _operationsByDay,
      _currentPrediction,
    ));
  }

  void onCreateOperation() {
    OperationWidget.showEdit(context: context).then((value) {
      if (value != null) {
        saveOperation(value);
      }
    });
  }

  Future<void> saveOperation(Operation data) async {
    await _operationService.save(data);
    _operations.replaceOperation(data);
    _prepareOperations(_operations);
    predictBudgetByDays();
  }

  Future<void> deleteOperation(Operation data) async {
    await _operationService.delete(data);
    _operations.deleteOperation(data);
    _prepareOperations(_operations);
    predictBudgetByDays();
  }

  void _prepareOperations(List<Operation> data) {
    _operations = data;
    _operationsByDay = _operations.groupBy((e) => e.date.date);
  }
}
