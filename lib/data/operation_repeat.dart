enum OperationRepeat {
  noRepeat,
  everyDay,
  everyWeek,
  everyTwoWeek,
  everyFourWeek,
  everyMonth,
  everyThreeMonth,
  everySixMonth,
  everyYear;

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

extension PeriodDateTime on DateTime {
  DateTime addTime({int year = 0, int month = 0, int day = 0}) {
    return DateTime(this.year + year, this.month + month, this.day + day, hour,
        minute, 0, 0, 0);
  }

  DateTime subtractTime({int year = 0, int month = 0, int day = 0}) {
    return DateTime(this.year - year, this.month - month, this.day - day, hour,
        minute, 0, 0, 0);
  }
}
