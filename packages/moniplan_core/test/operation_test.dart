import 'package:moniplan_core/moniplan_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

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
      // for (final e in expanded) {
      //   print(e);
      // }
    },
  );

  blocTest<OperationsManagerBloc, OperationsManagerState>(
    'test manager',
    build: () => OperationsManagerBloc(),
    act: (bloc) => bloc.computeBudget(OperationsManagerEvent.computeBudget(
      operations: [
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
        ...TestData.testRepeatOperations,
      ],
    )),
    verify: (bloc) {
      bloc.state.whenOrNull(
        budgetComputed: (orig, generated, budget) {
          budget.entries.forEach(print);
        },
      );
    },
  );
}
