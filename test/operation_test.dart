import 'package:flutter_test/flutter_test.dart';
import 'package:planimon/sdk/domain/operation.dart';

void main() {
  final firstDate = DateTime(2000, 1, 1, 4, 19);
  final secondDate = DateTime(2000, 1, 1, 5, 20);
  final thirdDate = DateTime(2000, 1, 20, 4, 20);

  test(
    "Cannot explicitly modify operations in record.",
    () {
      final record = BudgetEvent.single(operations: const [], date: firstDate);
      expect(
        () => record.operations
            .add(Operation.income(value: 1000, reason: "test")),
        throwsA(anything),
      );
    },
  );

  // test(
  //   "Records equated by day.",
  //   () {
  //     final firstRecordSingle =
  //         Record.single(operations: const [], date: firstDate);
  //     final secondRecordSingle =
  //         Record.single(operations: const [], date: secondDate);
  //     final thirdRecordSingle =
  //         Record.single(operations: const [], date: thirdDate);

  //     expect(firstRecordSingle == secondRecordSingle, true);
  //     expect(firstRecordSingle == thirdRecordSingle, false);
  //     expect(secondRecordSingle == thirdRecordSingle, false);

  //     final firstRecordPeriod = Record(
  //         operations: const [], dateStart: firstDate, dateEnd: thirdDate);
  //     final secondRecordPeriod = Record(
  //         operations: const [], dateStart: secondDate, dateEnd: thirdDate);

  //     expect(firstRecordPeriod == secondRecordPeriod, true);
  //   },
  // );

  test(
    "",
    () {},
  );
}
