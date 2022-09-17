import 'package:moniplan_core/moniplan_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:moniplan_core/src/usecases/generate_repeat_operations.dart';
import 'package:test/test.dart';

import '../lib/src/test/test_data.dart';

void main() {
  test(
    "expand operation",
    () {
      final now = DateTime.now();
      final operation = TestData.testRepeatOperations.first;
      final start = now.subtractTime(month: 4);
      final end = now.addTime(month: 2);
      print('Start: $start, End: $end');

      final expanded = GenerateRepeatOperationsUseCase(
        operation: operation,
        startPeriod: start,
        endPeriod: end,
      ).run();
    },
  );

  blocTest<OperationsManagerBloc, OperationsManagerState>(
    'test manager',
    build: () => OperationsManagerBloc(),
    act: (bloc) => bloc.computeBudget(OperationsManagerEvent.computeBudget(
      operations: [
        ...TestData.testRepeatOperations,
      ],
    )),
    verify: (bloc) {
      bloc.state.whenOrNull(
          // budgetComputed: (original, generated, budget) {
          //   budget.entries.forEach(print);
          // },
          );
    },
  );
}
