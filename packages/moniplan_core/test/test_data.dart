import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:uuid/uuid.dart';

abstract class TestData {
  static final testRepeatOperations = IList<Operation>([
    Operation(
      id: const Uuid().v4(),
      type: OperationType.income,
      currency: AppCurrencies.ru,
      date: DateTime.now(),
      money: 300,
      repeat: OperationRepeat.everyDay,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      money: 1300,
      date: DateTime.now().subtract(const Duration(days: 8)),
      repeat: OperationRepeat.everyWeek,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.transfer,
      currency: AppCurrencies.ru,
      money: 20,
      date: DateTime.now().add(const Duration(days: 8)),
      repeat: OperationRepeat.noRepeat,
    ),
  ]);
}
