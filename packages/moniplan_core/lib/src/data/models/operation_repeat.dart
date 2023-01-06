import 'package:moniplan_core/moniplan_core.dart';

enum OperationRepeat {
  noRepeat(''),
  everyDay('1d'),
  everyWeek('1w'),
  everyTwoWeek('2w'),
  everyFourWeek('4w'),
  everyMonth('1m'),
  everyThreeMonth('3m'),
  everySixMonth('6m'),
  everyYear('1y');

  final String shortName;

  const OperationRepeat(this.shortName);

  DateTime previous(DateTime base) {
    switch (this) {
      case OperationRepeat.noRepeat:
        return base;
      case OperationRepeat.everyDay:
        return base.subtractTime(day: 1);
      case OperationRepeat.everyWeek:
        return base.subtractTime(day: 7);
      case OperationRepeat.everyTwoWeek:
        return base.subtractTime(day: 14);
      case OperationRepeat.everyFourWeek:
        return base.subtractTime(day: 28);
      case OperationRepeat.everyMonth:
        return base.subtractTime(month: 1);
      case OperationRepeat.everyThreeMonth:
        return base.subtractTime(month: 3);
      case OperationRepeat.everySixMonth:
        return base.subtractTime(month: 6);
      case OperationRepeat.everyYear:
        return base.subtractTime(year: 1);
      default:
        return base;
    }
  }

  DateTime next(DateTime base) {
    switch (this) {
      case OperationRepeat.noRepeat:
        return base;
      case OperationRepeat.everyDay:
        return base.addTime(day: 1);
      case OperationRepeat.everyWeek:
        return base.addTime(day: 7);
      case OperationRepeat.everyTwoWeek:
        return base.addTime(day: 14);
      case OperationRepeat.everyFourWeek:
        return base.addTime(day: 28);
      case OperationRepeat.everyMonth:
        return base.addTime(month: 1);
      case OperationRepeat.everyThreeMonth:
        return base.addTime(month: 3);
      case OperationRepeat.everySixMonth:
        return base.addTime(month: 6);
      case OperationRepeat.everyYear:
        return base.addTime(year: 1);
      default:
        return base;
    }
  }
}
