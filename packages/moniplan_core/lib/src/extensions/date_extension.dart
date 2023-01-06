extension PeriodDateTime on DateTime {
  DateTime get onlyDate => DateTime(year, month, day);

  DateTime addTime({int year = 0, int month = 0, int day = 0}) {
    return DateTime(this.year + year, this.month + month, this.day + day, hour,
        minute, 0, 0, 0);
  }

  DateTime subtractTime({int year = 0, int month = 0, int day = 0}) {
    return DateTime(this.year - year, this.month - month, this.day - day, hour,
        minute, 0, 0, 0);
  }

  DateTime get monthStart => DateTime(year, month, 1);
  DateTime get monthMedian => monthStart.add(const Duration(days: 14));
  DateTime get monthEnd => DateTime(year, month + 1, 0);
}
