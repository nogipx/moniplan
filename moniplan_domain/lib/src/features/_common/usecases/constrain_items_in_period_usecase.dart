import 'package:moniplan_domain/moniplan_domain.dart';

/// Based on given dates boundaries, filters the items
/// that are limited by these boundaries.
class ConstrainItemsInPeriodUseCase<T> implements IUseCase<List<T>> {
  final Iterable<T> items;
  final DateTime dateStart;
  final DateTime dateEnd;
  final DateTime Function(T) dateExtractor;

  const ConstrainItemsInPeriodUseCase({
    required this.items,
    required this.dateStart,
    required this.dateEnd,
    required this.dateExtractor,
  });

  @override
  List<T> run() {
    final start = dateStart.onlyDate;
    final end = dateEnd.onlyDate;

    final constrained = items.where((item) {
      final itemDate = dateExtractor(item).onlyDate;

      final startCompare = itemDate.compareTo(start);
      final endCompare = itemDate.compareTo(end);

      final isInConstraintStart = startCompare == 1 || startCompare == 0;
      final isInConstraintEnd = endCompare == -1 || endCompare == 0;

      return isInConstraintStart && isInConstraintEnd;
    }).toList();

    return constrained;
  }
}
