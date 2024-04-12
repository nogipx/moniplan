import 'package:moniplan_domain/moniplan_domain.dart';

class ConstrainItemsInPeriodArgs<T> {
  final Iterable<T> items;
  final DateTime dateStart;
  final DateTime dateEnd;
  final DateTime Function(T) dateExtractor;

  const ConstrainItemsInPeriodArgs({
    required this.items,
    required this.dateStart,
    required this.dateEnd,
    required this.dateExtractor,
  });
}

class ConstrainItemsInPeriodResult<T> {
  final List<T> constrained;

  const ConstrainItemsInPeriodResult({
    required this.constrained,
  });
}

class ConstrainItemsInPeriod<T> implements UseCase<ConstrainItemsInPeriodResult<T>> {
  final ConstrainItemsInPeriodArgs<T> args;

  const ConstrainItemsInPeriod({
    required this.args,
  });

  @override
  ConstrainItemsInPeriodResult<T> run() {
    final start = args.dateStart.onlyDate;
    final end = args.dateEnd.onlyDate;

    final constrained = args.items.where((item) {
      final itemDate = args.dateExtractor(item).onlyDate;

      final startCompare = itemDate.compareTo(start);
      final endCompare = itemDate.compareTo(end);

      final isInConstraintStart = startCompare == 1 || startCompare == 0;
      final isInConstraintEnd = endCompare == -1 || endCompare == 0;

      return isInConstraintStart && isInConstraintEnd;
    }).toList();

    return ConstrainItemsInPeriodResult(
      constrained: constrained,
    );
  }
}
