/// Расширения для DateTime
extension DateTimeExtensions on DateTime {
  /// Возвращает дату без времени (время устанавливается в 00:00:00)
  DateTime get dateOnly => DateTime(year, month, day);

  /// Возвращает true, если дата находится в прошлом (без учета времени)
  bool get isPast => dateOnly.isBefore(DateTime.now().dateOnly);

  /// Возвращает true, если дата находится в будущем (без учета времени)
  bool get isFuture => dateOnly.isAfter(DateTime.now().dateOnly);

  /// Возвращает true, если дата - сегодня (без учета времени)
  bool get isToday => dateOnly == DateTime.now().dateOnly;

  /// Возвращает true, если дата - вчера (без учета времени)
  bool get isYesterday => dateOnly == DateTime.now().dateOnly.subtract(const Duration(days: 1));

  /// Возвращает true, если дата - завтра (без учета времени)
  bool get isTomorrow => dateOnly == DateTime.now().dateOnly.add(const Duration(days: 1));

  /// Возвращает true, если дата находится в текущем месяце
  bool get isCurrentMonth => year == DateTime.now().year && month == DateTime.now().month;

  /// Возвращает true, если дата находится в текущем году
  bool get isCurrentYear => year == DateTime.now().year;

  /// Возвращает первый день месяца
  DateTime get firstDayOfMonth => DateTime(year, month);

  /// Возвращает последний день месяца
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  /// Возвращает первый день года
  DateTime get firstDayOfYear => DateTime(year);

  /// Возвращает последний день года
  DateTime get lastDayOfYear => DateTime(year, 12, 31);

  /// Возвращает количество дней в месяце
  int get daysInMonth => lastDayOfMonth.day;

  /// Возвращает номер недели в году
  int get weekOfYear {
    final firstDayOfYear = DateTime(year);
    final dayOfYear = difference(firstDayOfYear).inDays;
    return ((dayOfYear + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  /// Возвращает номер дня в году
  int get dayOfYear => difference(firstDayOfYear).inDays + 1;

  /// Возвращает true, если год високосный
  bool get isLeapYear => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Возвращает количество дней в году
  int get daysInYear => isLeapYear ? 366 : 365;

  /// Возвращает true, если дата - выходной (суббота или воскресенье)
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Возвращает true, если дата - рабочий день (не суббота и не воскресенье)
  bool get isWeekday => !isWeekend;

  /// Возвращает дату с заданным временем
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
