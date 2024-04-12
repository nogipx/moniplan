import 'package:moniplan_domain/moniplan_domain.dart';

enum DateTimeRepeat {
  noRepeat(''),
  day('1d'),
  twoDays('2d'),
  threeDays('3d'),
  fourDays('4d'),
  fiveDays('5d'),
  sixDays('6d'),
  week('1w'),
  twoWeek('2w'),
  threeWeek('1w'),
  fourWeek('4w'),
  month('1m'),
  threeMonths('3m'),
  sixMonths('6m'),
  year('1y');

  final String shortName;

  const DateTimeRepeat(this.shortName);

  DateTime previous(DateTime base) {
    final result = switch (this) {
      DateTimeRepeat.noRepeat => base,
      DateTimeRepeat.day => base.subtractTime(day: 1),
      DateTimeRepeat.twoDays => base.subtractTime(day: 2),
      DateTimeRepeat.threeDays => base.subtractTime(day: 3),
      DateTimeRepeat.fourDays => base.subtractTime(day: 4),
      DateTimeRepeat.fiveDays => base.subtractTime(day: 5),
      DateTimeRepeat.sixDays => base.subtractTime(day: 6),
      DateTimeRepeat.week => base.subtractTime(day: 7),
      DateTimeRepeat.twoWeek => base.subtractTime(day: 14),
      DateTimeRepeat.threeWeek => base.subtractTime(day: 21),
      DateTimeRepeat.fourWeek => base.subtractTime(day: 28),
      DateTimeRepeat.month => base.subtractTime(month: 1),
      DateTimeRepeat.threeMonths => base.subtractTime(month: 3),
      DateTimeRepeat.sixMonths => base.subtractTime(month: 6),
      DateTimeRepeat.year => base.subtractTime(year: 1),
    };
    return result;
  }

  DateTime next(DateTime base) {
    final result = switch (this) {
      DateTimeRepeat.noRepeat => base,
      DateTimeRepeat.day => base.addTime(day: 1),
      DateTimeRepeat.twoDays => base.addTime(day: 2),
      DateTimeRepeat.threeDays => base.addTime(day: 3),
      DateTimeRepeat.fourDays => base.addTime(day: 4),
      DateTimeRepeat.fiveDays => base.addTime(day: 5),
      DateTimeRepeat.sixDays => base.addTime(day: 6),
      DateTimeRepeat.week => base.addTime(day: 7),
      DateTimeRepeat.twoWeek => base.addTime(day: 14),
      DateTimeRepeat.threeWeek => base.addTime(day: 21),
      DateTimeRepeat.fourWeek => base.addTime(day: 28),
      DateTimeRepeat.month => base.addTime(month: 1),
      DateTimeRepeat.threeMonths => base.addTime(month: 3),
      DateTimeRepeat.sixMonths => base.addTime(month: 6),
      DateTimeRepeat.year => base.addTime(year: 1),
    };
    return result;
  }
}
