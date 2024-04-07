import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:uuid/uuid.dart';

abstract class TestData {
  static final testRepeatPayments = IList<Payment>([
    // Payment(
    //   id: const Uuid().v4(),
    //   type: PaymentType.income,
    //   currency: AppCurrencies.ru,
    //   date: PaymentDateDateTime.now(),
    //   money: 300,
    //   repeat: PaymentRepeat.everyWeek,
    // ),
    // Payment(
    //   id: const Uuid().v4(),
    //   type: PaymentType.outcome,
    //   currency: AppCurrencies.ru,
    //   money: 1300,
    //   date: DateTime.now().subtract(const Duration(days: 8)),
    //   repeat: PaymentRepeat.everyMonth,
    // ),
    // Payment(
    //   id: const Uuid().v4(),
    //   type: PaymentType.transfer,
    //   currency: AppCurrencies.ru,
    //   money: 20,
    //   date: DateTime.now().add(const Duration(days: 8)),
    //   repeat: PaymentRepeat.noRepeat,
    // ),
  ]);
}
