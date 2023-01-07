import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/usecases/_usecase.dart';

class GenerateRepeatDatesUseCase extends UseCase<List<DateTime>> {
  final DateTimeRepeat repeat;
  final DateTime base;
  final DateTime dateStart;
  final DateTime dateEnd;

  const GenerateRepeatDatesUseCase({
    required this.repeat,
    required this.base,
    required this.dateStart,
    required this.dateEnd,
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

    if (hasPastDays) {
      pastDates.add(repeat.previous(base));
      while (true) {
        final next = repeat.previous(pastDates.last);
        if (next.compareTo(dateStart) >= 0) {
          pastDates.add(next);
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
          futureDates.add(next);
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
