import 'package:bloc/bloc.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:dartx/dartx.dart';
import 'package:uuid/uuid.dart';

class BudgetPredictionCubit extends Cubit<BudgetPredictionState> {
  BudgetPredictionCubit() : super(PredictionInitial());

  void predictBudgetByDays(List<Operation> events) {
    final predictions = <DateTime, Prediction>{};
    events
        .groupBy((e) => e.date.date)
        .entries
        .sortedBy((e) => e.key)
        .map((e) => MapEntry(
            e.key,
            Prediction(
                id: Uuid().v4(), operations: e.value, budget: e.value.total)))
        .fold<MapEntry<DateTime, Prediction>>(
      MapEntry(
        DateTime.now(),
        Prediction(
          id: Uuid().v4(),
          operations: const [],
          budget: 0,
        ),
      ),
      (prev, curr) {
        final prediction = curr.value.copyWith(
          budget: prev.value.budget + curr.value.budget,
        );
        predictions[curr.key] = prediction;
        return MapEntry(curr.key, prediction);
      },
    );
    emit(PredictionSuccess(predictions));
  }
}

//

abstract class BudgetPredictionState {}

class PredictionInitial extends BudgetPredictionState {}

class PredictionSuccess extends BudgetPredictionState {
  final Map<DateTime, Prediction> events;

  PredictionSuccess(this.events);
}

class PredictionInProgress extends BudgetPredictionState {}
