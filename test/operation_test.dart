import 'package:flutter_test/flutter_test.dart';
import 'package:moniplan/data/operation_repeat.dart';
import 'package:moniplan/data/operation_virtual.dart';

import 'test_data.dart';

void main() {
  test(
    "expand operation",
    () {
      final now = DateTime.now();
      final operation = TestData.testRepeatOperations.first;
      final start = now.subtractTime(month: 4);
      final end = now.addTime(month: 2);
      print('Start: $start, End: $end');

      final expanded = operation.getPeriodOperations(start, end);
      for (final e in expanded) {
        print(e);
      }
    },
  );
}
