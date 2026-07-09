import 'package:meta/meta.dart';

/// MROT history for the lower bound of the average (clause 18 of Decree 922).
@immutable
class MrotHistory {
  const MrotHistory(this.points);

  /// Ascending by date; each entry is (effectiveFrom, value).
  final List<MrotPoint> points;

  factory MrotHistory.ru() => MrotHistory([
        MrotPoint(DateTime(2024, 1, 1), 19242),
        MrotPoint(DateTime(2025, 1, 1), 22440),
        MrotPoint(DateTime(2026, 1, 1), 27093),
      ]);

  num valueAt(DateTime date) {
    num value = points.first.value;
    for (final p in points) {
      if (!p.effectiveFrom.isAfter(date)) {
        value = p.value;
      }
    }
    return value;
  }
}

@immutable
class MrotPoint {
  const MrotPoint(this.effectiveFrom, this.value);

  final DateTime effectiveFrom;
  final num value;
}
