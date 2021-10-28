import 'dart:collection';

import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';
import 'package:uuid/uuid.dart';

extension OperationPredictionList on List<Operation> {
  LinkedHashMap<DateTime, Prediction> predict() {
    final predictions = LinkedHashMap<DateTime, Prediction>();
    groupBy((e) => e.date.date)
        .entries
        .sortedBy((e) => e.key)
        .map(
          (e) => MapEntry(
            e.key,
            Prediction(
              id: Uuid().v4(),
              operations: e.value,
              budget: e.value.total,
            ),
          ),
        )
        .fold<MapEntry<DateTime, Prediction>>(
      MapEntry(
        DateTime.now(),
        Prediction(
          id: Uuid().v4(),
          operations: const [],
          budget: 0,
        ),
      ),
      (prev, curr) {
        final prediction = curr.value.copyWith(
          budget: prev.value.budget + curr.value.budget,
        );
        predictions[curr.key] = prediction;
        return MapEntry(curr.key, prediction);
      },
    );
    return predictions;
  }
}
