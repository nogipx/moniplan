import 'package:bloc/bloc.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/sdk/service/record_service.dart';
import 'package:dartx/dartx.dart';

class BudgetPredictionBloc
    extends Bloc<BudgetPredictionEvent, BudgetPredictionState> {
  final BudgetEventService eventService;

  BudgetPredictionBloc({
    required this.eventService,
  }) : super(PredictionInitial());

  @override
  Stream<BudgetPredictionState> mapEventToState(
      BudgetPredictionEvent event) async* {
    if (event is PredictionComputed) {
      yield PredictionSuccess(_predictBudget(eventService.getEvents()));
    } else {
      yield PredictionInProgress();
    }
  }

  Map<DateTime, List<BudgetPrediction>> _predictBudget(
      List<BudgetEvent> events) {
    events.sort((a, b) => a.dateStart.date.compareTo(b.dateStart.date));
    if (events.isEmpty) {
      return {};
    }

    final List<BudgetPrediction> predictions = [
      BudgetPrediction(events.first.total, events.first),
    ];

    events.map((e) => BudgetPrediction(e.total, e)).reduce((prev, cur) {
      final prediction =
          BudgetPrediction(prev.predictionValue + cur.predictionValue, cur);
      predictions.add(prediction);
      return prediction;
    });

    return predictions.groupBy((e) => e.dateStart.date);
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
  final Map<DateTime, List<BudgetPrediction>> events;

  PredictionSuccess(this.events);
}

class PredictionInProgress extends BudgetPredictionState {}
