import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:moniplan/sdk/domain.dart';

class BudgetPredictionCubit extends Cubit<BudgetPredictionState> {
  BudgetPredictionCubit() : super(PredictionInitial());

  void predictBudgetByDays(List<Operation> events) {
    emit(PredictionSuccess(events.predict()));
  }
}

abstract class BudgetPredictionState {}

class PredictionInitial extends BudgetPredictionState {}

class PredictionSuccess extends BudgetPredictionState {
  final LinkedHashMap<DateTime, Prediction> events;

  PredictionSuccess(this.events);
}

class PredictionInProgress extends BudgetPredictionState {}
