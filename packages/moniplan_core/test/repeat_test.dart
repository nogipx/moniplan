import 'package:moniplan_core/moniplan_core.dart';

void main() {
  final now = DateTime.now();

  final base = now.subtractTime(month: 3);
  final start = now.monthStart;
  final end = now.addTime(month: 1).monthEnd;

  final list = GenerateRepeatDatesUseCase(
    repeat: DateTimeRepeat.everyWeek,
    base: base,
    dateStart: start,
    dateEnd: end,
  ).run();

  print('Base: $base');
  print('Start: $start');
  print('End: $end');
  print('');

  list.forEach(print);
}
