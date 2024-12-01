extension PeriodDateTime on DateTime {
  DateTime get monthBound => DateTime(year, month);

  DateTime get dayBound => DateTime(year, month, day);

  DateTime get minuteBound => DateTime(year, month, day, hour, minute);

  bool isMonthEdge({
    required DateTime? prevDate,
    required DateTime? nextDate,
  }) {
    if (prevDate == null && nextDate != null) {
      return true;
    } else if (prevDate != null && nextDate == null) {
      return false;
    } else if (prevDate != null && prevDate.month != month) {
      return true;
    }

    return false;
  }

  DateTime addTime({int year = 0, int month = 0, int day = 0}) {
    return DateTime(this.year + year, this.month + month, this.day + day, hour, minute, 0, 0, 0);
  }

  DateTime subtractTime({int year = 0, int month = 0, int day = 0}) {
    return DateTime(this.year - year, this.month - month, this.day - day, hour, minute, 0, 0, 0);
  }

  DateTime get monthStart => DateTime(year, month, 1);
  DateTime get monthMedian => monthStart.add(const Duration(days: 14));
  DateTime get monthEnd => DateTime(year, month + 1, 0);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  static DateTime currentYear({
    required int day,
    int? month,
  }) {
    final now = DateTime.now();
    return DateTime(now.year, month ?? now.month, day);
  }
}
