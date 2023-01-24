import 'package:moniplan_core/moniplan_core.dart';

enum DateTimeRepeat {
  noRepeat(''),
  everyDay('1d'),
  everyTwoDay('2d'),
  everyThreeDay('3d'),
  everyFourDay('4d'),
  everyFiveDay('5d'),
  everySixDay('6d'),
  everyWeek('1w'),
  everyTwoWeek('2w'),
  everyFourWeek('4w'),
  everyMonth('1m'),
  everyThreeMonth('3m'),
  everySixMonth('6m'),
  everyYear('1y');

  final String shortName;

  const DateTimeRepeat(this.shortName);

  DateTime previous(DateTime base) {
    switch (this) {
      case DateTimeRepeat.noRepeat:
        return base;
      case DateTimeRepeat.everyDay:
        return base.subtractTime(day: 1);
      case DateTimeRepeat.everyTwoDay:
        return base.subtractTime(day: 2);
      case DateTimeRepeat.everyThreeDay:
        return base.subtractTime(day: 3);
      case DateTimeRepeat.everyFourDay:
        return base.subtractTime(day: 4);
      case DateTimeRepeat.everyFiveDay:
        return base.subtractTime(day: 5);
      case DateTimeRepeat.everySixDay:
        return base.subtractTime(day: 6);
      case DateTimeRepeat.everyWeek:
        return base.subtractTime(day: 7);
      case DateTimeRepeat.everyTwoWeek:
        return base.subtractTime(day: 14);
      case DateTimeRepeat.everyFourWeek:
        return base.subtractTime(day: 28);
      case DateTimeRepeat.everyMonth:
        return base.subtractTime(month: 1);
      case DateTimeRepeat.everyThreeMonth:
        return base.subtractTime(month: 3);
      case DateTimeRepeat.everySixMonth:
        return base.subtractTime(month: 6);
      case DateTimeRepeat.everyYear:
        return base.subtractTime(year: 1);
      default:
        return base;
    }
  }

  DateTime next(DateTime base) {
    switch (this) {
      case DateTimeRepeat.noRepeat:
        return base;
      case DateTimeRepeat.everyDay:
        return base.addTime(day: 1);
      case DateTimeRepeat.everyTwoDay:
        return base.addTime(day: 2);
      case DateTimeRepeat.everyThreeDay:
        return base.addTime(day: 3);
      case DateTimeRepeat.everyFourDay:
        return base.addTime(day: 4);
      case DateTimeRepeat.everyFiveDay:
        return base.addTime(day: 5);
      case DateTimeRepeat.everySixDay:
        return base.addTime(day: 6);
      case DateTimeRepeat.everyWeek:
        return base.addTime(day: 7);
      case DateTimeRepeat.everyTwoWeek:
        return base.addTime(day: 14);
      case DateTimeRepeat.everyFourWeek:
        return base.addTime(day: 28);
      case DateTimeRepeat.everyMonth:
        return base.addTime(month: 1);
      case DateTimeRepeat.everyThreeMonth:
        return base.addTime(month: 3);
      case DateTimeRepeat.everySixMonth:
        return base.addTime(month: 6);
      case DateTimeRepeat.everyYear:
        return base.addTime(year: 1);
      default:
        return base;
    }
  }
}
