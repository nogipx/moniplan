import 'package:moniplan/sdk/domain.dart';

abstract class BudgetEventService {
  List<Prediction> getEvents();

  Map<DateTime, List<Prediction>> getEventsByDays();

  static const boxName = "budget_event";

  Future<void> save(Prediction event);
  Future<void> delete(Prediction event);
}
