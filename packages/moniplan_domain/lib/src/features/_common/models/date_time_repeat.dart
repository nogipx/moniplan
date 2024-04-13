import 'package:moniplan_domain/moniplan_domain.dart';

enum DateTimeRepeat {
  noRepeat('', 0),
  day('1d', 1),
  twoDays('2d', 2),
  threeDays('3d', 3),
  fourDays('4d', 4),
  fiveDays('5d', 5),
  sixDays('6d', 6),
  week('1w', 7),
  twoWeek('2w', 8),
  threeWeek('3w', 9),
  fourWeek('4w', 10),
  month('1m', 11),
  threeMonths('3m', 13),
  sixMonths('6m', 16),
  year('1y', 22);

  final String shortName;
  final int id;

  const DateTimeRepeat(this.shortName, this.id);

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

  static from(int? id) {
    return switch (id) {
      0 => DateTimeRepeat.noRepeat,
      1 => DateTimeRepeat.day,
      2 => DateTimeRepeat.twoDays,
      3 => DateTimeRepeat.threeDays,
      4 => DateTimeRepeat.fourDays,
      5 => DateTimeRepeat.fiveDays,
      6 => DateTimeRepeat.sixDays,
      7 => DateTimeRepeat.week,
      8 => DateTimeRepeat.twoWeek,
      9 => DateTimeRepeat.threeWeek,
      10 => DateTimeRepeat.fourWeek,
      11 => DateTimeRepeat.month,
      13 => DateTimeRepeat.threeMonths,
      16 => DateTimeRepeat.sixMonths,
      22 => DateTimeRepeat.year,
      _ => DateTimeRepeat.noRepeat,
    };
  }
}
