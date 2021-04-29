import 'package:planimon/sdk/domain.dart';
import 'package:planimon/sdk/service/record_service.dart';
import 'package:hive/hive.dart';
import 'package:dartx/dartx.dart';

class BudgetEventServiceHive implements BudgetEventService {
  final Box<BudgetEvent> hive;

  BudgetEventServiceHive({required this.hive});

  @override
  Future<void> delete(BudgetEvent event) async {
    hive.delete(event.id);
  }

  @override
  List<BudgetEvent> getEvents() {
    final data = hive.toMap();
    return data.values.toList();
  }

  @override
  Map<DateTime, List<BudgetEvent>> getEventsByDays() {
    final data = getEvents();
    return data.groupBy((e) => e.dateStart.date);
  }

  @override
  Future<void> save(BudgetEvent event) async {
    hive.put(event.id, event);
  }
}
