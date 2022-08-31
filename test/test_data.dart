import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:money2/money2.dart';
import 'package:moniplan/data/operation_repeat.dart';
import 'package:moniplan/data/operation_type.dart';
import 'package:moniplan/data/operation_virtual.dart';
import 'package:moniplan/useful/currency_extension.dart';
import 'package:uuid/uuid.dart';

abstract class TestData {
  static final testRepeatOperations = IList<Operation>([
    Operation(
      id: const Uuid().v4(),
      type: OperationType.income,
      currency: AppCurrencies.ru,
      date: DateTime.now(),
      repeat: OperationRepeat.everyDay,
    ),
  ]);
}
