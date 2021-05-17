import 'package:bloc/bloc.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';
import 'package:uuid/uuid.dart';

class BudgetPredictionBloc
    extends Bloc<BudgetPredictionEvent, BudgetPredictionState> {
  final OperationService eventService;

  BudgetPredictionBloc({
    required this.eventService,
  }) : super(PredictionInitial());

  @override
  Stream<BudgetPredictionState> mapEventToState(
      BudgetPredictionEvent event) async* {
    if (event is PredictionComputed) {
      yield PredictionSuccess(predictBudget(eventService.getAll()));
    } else {
      yield PredictionInProgress();
    }
  }

  Map<DateTime, BudgetPrediction> predictBudget(List<Operation> events) {
    final predictions = <DateTime, BudgetPrediction>{};
    events
        .groupBy((e) => e.date.date)
        .entries
        .sortedBy((e) => e.key)
        .map((e) => MapEntry(
            e.key,
            BudgetPrediction(
                id: Uuid().v4(),
                operations: e.value,
                predictionValue: e.value.total)))
        .fold<MapEntry<DateTime, BudgetPrediction>>(
      MapEntry(
        DateTime.now(),
        BudgetPrediction(
          id: Uuid().v4(),
          operations: const [],
          predictionValue: 0,
        ),
      ),
      (prev, curr) {
        predictions[curr.key] = curr.value.copyWith(
          predictionValue:
              prev.value.predictionValue + curr.value.predictionValue,
        );
        return curr;
      },
    );

    return predictions;
  }

  void compute() => add(PredictionComputed());
}

//

abstract class BudgetPredictionEvent {}

class PredictionComputed extends BudgetPredictionEvent {}

//

abstract class BudgetPredictionState {}

class PredictionInitial extends BudgetPredictionState {}

class PredictionSuccess extends BudgetPredictionState {
  final Map<DateTime, BudgetPrediction> events;

  PredictionSuccess(this.events);
}

class PredictionInProgress extends BudgetPredictionState {}
