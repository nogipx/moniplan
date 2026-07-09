/// RF production calendar (spec 3.2, 5.1).
///
/// Two distinct notions:
///  - [isPublicHoliday]: the non-working public holidays of art. 112 (fixed
///    dates). Used to exclude days from paid vacation (art. 120).
///  - [isWorkingDay]: the full production calendar (weekends + holidays +
///    transfers). Used for salary proration and payday shifting (art. 136).
///
/// Transfers (переносы) are updated once a year by government decree. For now
/// only the fixed art. 112 dates and plain weekends are modeled; explicit
/// transfer sets can be supplied per year.
class ProductionCalendar {
  ProductionCalendar({
    Set<int>? publicHolidayKeys,
    Set<int>? extraNonWorkingKeys,
    Set<int>? workingWeekendKeys,
  })  : _publicHolidayKeys = publicHolidayKeys ?? _defaultPublicHolidays(),
        _extraNonWorkingKeys = extraNonWorkingKeys ?? const <int>{},
        _workingWeekendKeys = workingWeekendKeys ?? const <int>{};

  /// Federal defaults (fixed art. 112 dates, no transfers modeled).
  factory ProductionCalendar.ru() => ProductionCalendar();

  final Set<int> _publicHolidayKeys;
  final Set<int> _extraNonWorkingKeys;
  final Set<int> _workingWeekendKeys;

  static int _key(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day, 12);

  /// Non-working public holiday per art. 112 (excluded from paid vacation).
  bool isPublicHoliday(DateTime d) => _publicHolidayKeys.contains(_key(d));

  /// Production-calendar working day.
  bool isWorkingDay(DateTime d) {
    final k = _key(d);
    if (_publicHolidayKeys.contains(k) || _extraNonWorkingKeys.contains(k)) {
      return false;
    }
    final wd = d.weekday;
    final isWeekend = wd == DateTime.saturday || wd == DateTime.sunday;
    if (isWeekend) return _workingWeekendKeys.contains(k);
    return true;
  }

  /// Inclusive count of working days in [a, b].
  int workingDaysBetween(DateTime a, DateTime b) {
    var d = _dateOnly(a);
    final end = _dateOnly(b);
    var count = 0;
    while (!d.isAfter(end)) {
      if (isWorkingDay(d)) count++;
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  /// Inclusive count of art. 112 holidays in [a, b].
  int publicHolidaysBetween(DateTime a, DateTime b) {
    var d = _dateOnly(a);
    final end = _dateOnly(b);
    var count = 0;
    while (!d.isAfter(end)) {
      if (isPublicHoliday(d)) count++;
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  int workingDaysInMonth(int year, int month) {
    final first = DateTime(year, month, 1);
    final last = DateTime(year, month + 1, 0);
    return workingDaysBetween(first, last);
  }

  /// Nearest working day on or before [d].
  DateTime previousWorkingDay(DateTime d) {
    var cur = _dateOnly(d);
    while (!isWorkingDay(cur)) {
      cur = cur.subtract(const Duration(days: 1));
    }
    return DateTime(cur.year, cur.month, cur.day);
  }

  /// Art. 112 non-working holidays, same dates every year, for 2024..2030.
  /// New Year holidays Jan 1-8, Jan 7 Christmas, Feb 23, Mar 8, May 1, May 9,
  /// Jun 12, Nov 4.
  static Set<int> _defaultPublicHolidays() {
    const fixed = <List<int>>[
      [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7], [1, 8],
      [2, 23],
      [3, 8],
      [5, 1],
      [5, 9],
      [6, 12],
      [11, 4],
    ];
    final keys = <int>{};
    for (var year = 2024; year <= 2030; year++) {
      for (final md in fixed) {
        keys.add(year * 10000 + md[0] * 100 + md[1]);
      }
    }
    return keys;
  }
}
