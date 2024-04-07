import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:moniplan_core/moniplan_core.dart';

abstract class PaymentDataSource {
  IList<Payment> getAll();
  Payment getById(String id);
  Payment create(Payment data);
  Payment delete(String id);
  Payment update(Payment data);
}
