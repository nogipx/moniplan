import 'package:meta/meta.dart';

/// CBR key rate history for art. 236 late-payment compensation (spec 3.2).
/// Used in a later increment; structure defined now.
@immutable
class KeyRateHistory {
  const KeyRateHistory(this.points);

  /// Ascending by date; each entry is (effectiveFrom, rate as fraction).
  final List<KeyRatePoint> points;

  factory KeyRateHistory.ru() => KeyRateHistory([
        KeyRatePoint(DateTime(2024, 12, 28), 0.21),
        KeyRatePoint(DateTime(2025, 6, 9), 0.20),
        KeyRatePoint(DateTime(2025, 7, 28), 0.18),
      ]);

  num rateAt(DateTime date) {
    num rate = points.first.rate;
    for (final p in points) {
      if (!p.effectiveFrom.isAfter(date)) {
        rate = p.rate;
      }
    }
    return rate;
  }
}

@immutable
class KeyRatePoint {
  const KeyRatePoint(this.effectiveFrom, this.rate);

  final DateTime effectiveFrom;
  final num rate;
}
