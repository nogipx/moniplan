import 'package:planimon/sdk/domain.dart';
import 'package:planimon/sdk/service/record_service.dart';
import 'package:dartx/dartx.dart';

class BudgetEventServiceTestImpl implements BudgetEventService {
  @override
  List<BudgetEvent> getEvents() {
    final now = DateTime.now().date;
    return [
      BudgetEvent.single(
        date: DateTime(2021, 4, 14),
        operations: [
          Operation.income(value: 41000, reason: "Было"),
          Operation.income(value: 78300, reason: "Зп"),
          Operation.outcome(value: 8000, reason: "Куда-то просраны")
        ],
      ),
      BudgetEvent.single(
        date: DateTime(2021, 4, 15),
        operations: [Operation.outcome(value: 4000, reason: "Кредит Skillbox")],
      ),
      BudgetEvent.single(
        date: DateTime(2021, 4, 23),
        operations: [Operation.outcome(value: 4600, reason: "Кредит MacBook")],
      ),
      BudgetEvent.single(
        date: DateTime(2021, 4, 15),
        operations: [
          Operation.outcome(value: 15000, reason: "Новая квартира"),
          Operation.outcome(value: 15000, reason: "Залог"),
        ],
      ),
      BudgetEvent.single(
        date: DateTime(2021, 4, 15),
        operations: [
          Operation.outcome(value: 1007.85, reason: "ЖКУ"),
          Operation.outcome(value: 1727.13, reason: "ИРЦК"),
          Operation.outcome(value: 206.64, reason: "Мусор"),
          Operation.outcome(value: 685.33, reason: "Водоканал"),
        ],
      ),
      BudgetEvent.single(
        date: DateTime(2021, 4, 16),
        operations: [
          Operation.outcome(value: 60000, reason: 'Кредиты мамы', enabled: true)
        ],
      ),
    ];
  }

  @override
  Map<DateTime, List<BudgetEvent>> getEventsByDays() {
    return getEvents().groupBy((e) => e.dateStart);
  }

  @override
  Future<void> delete(BudgetEvent event) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> save(BudgetEvent event) {
    // TODO: implement save
    throw UnimplementedError();
  }
}
