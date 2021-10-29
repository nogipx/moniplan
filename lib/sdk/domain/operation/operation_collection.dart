import 'dart:collection';

import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';

extension OperationPredictionList on List<Operation> {
  SplayTreeMap<DateTime, double> predict() {
    final dailyResult = SplayTreeMap<DateTime, double>(
      (date1, date2) => date1.compareTo(date2),
    );

    // Group operations values by day
    map((e) => MapEntry(e.date.date, e.result)).forEach((e) {
      final singleDayResult = dailyResult.putIfAbsent(e.key, () => 0);
      dailyResult[e.key] = singleDayResult + e.value;
    });

    // Compute predictions
    dailyResult.entries.reduce((prev, curr) {
      final newValue = curr.value + prev.value;
      dailyResult.update(curr.key, (_) => newValue);
      return MapEntry(curr.key, newValue);
    });

    return dailyResult;
  }
}
