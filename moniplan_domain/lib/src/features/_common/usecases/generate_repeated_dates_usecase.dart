import 'package:moniplan_domain/moniplan_domain.dart';

/// Based on the repetition setting, dates are generated
/// that are limited by the specified date boundaries.
/// This requires some starting date from which the rest will be generated.
/// Both future and past dates from the specified date are generated.
class GenerateRepeatDatesUseCase implements IUseCase<List<DateTime>> {
  final DateTimeRepeat repeat;
  final DateTime base;
  final DateTime dateStart;
  final DateTime dateEnd;

  final bool generatePastDates;

  const GenerateRepeatDatesUseCase({
    required this.repeat,
    required this.base,
    required this.dateStart,
    required this.dateEnd,
    this.generatePastDates = false,
  });

  @override
  List<DateTime> run() {
    final hasPastDays = repeat.previous(base).compareTo(dateStart) >= 0;
    final hasFutureDays = repeat.next(base).compareTo(dateEnd) <= 0;

    final pastDates = <DateTime>[];
    final futureDates = <DateTime>[];

    /// Generation can be optimised by memory used:
    /// if next/previous date is not in the desired range
    /// then do not add it to the list, but cache it in one variable

    if (generatePastDates && hasPastDays) {
      pastDates.add(repeat.previous(base));
      while (true) {
        final next = repeat.previous(pastDates.last);
        if (next.compareTo(dateStart) >= 0) {
          if (next.isAfter(dateEnd)) {
            pastDates[0] = next;
          } else {
            pastDates.add(next);
          }
        } else {
          break;
        }
      }
    }

    if (hasFutureDays) {
      futureDates.add(repeat.next(base));
      while (true) {
        final next = repeat.next(futureDates.last);
        if (next.compareTo(dateEnd) <= 0) {
          if (next.isBefore(dateStart)) {
            futureDates[0] = next;
          } else {
            futureDates.add(next);
          }
        } else {
          break;
        }
      }
    }

    return [
      ...pastDates.reversed,
      base,
      ...futureDates,
    ]
        .where((e) => e.compareTo(dateStart) >= 0 && e.compareTo(dateEnd) <= 0)
        .toList();
  }
}
