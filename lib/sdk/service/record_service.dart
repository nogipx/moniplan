import 'package:moniplan/sdk/domain.dart';

abstract class BudgetEventService {
  List<BudgetEvent> getEvents();

  Map<DateTime, List<BudgetEvent>> getEventsByDays();

  static const boxName = "budget_event";

  Future<void> save(BudgetEvent event);
  Future<void> delete(BudgetEvent event);
}
