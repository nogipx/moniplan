import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  final now = DateTime.now();

  final base = now.subtractTime(month: 3);
  final start = now.monthStart;
  final end = now.addTime(month: 1).monthEnd;

  final list = GenerateRepeatDatesUseCase(
    repeat: DateTimeRepeat.week,
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
