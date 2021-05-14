import 'package:moniplan/sdk/domain.dart';

abstract class BudgetEventService {
  List<BudgetPrediction> getEvents();

  Map<DateTime, List<BudgetPrediction>> getEventsByDays();

  static const boxName = "budget_event";

  Future<void> save(BudgetPrediction event);
  Future<void> delete(BudgetPrediction event);
}
