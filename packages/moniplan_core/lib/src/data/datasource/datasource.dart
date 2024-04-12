import 'package:moniplan_core/moniplan_core.dart';

abstract class PaymentDataSource {
  List<Payment> getAll();
  Payment getById(String id);
  Payment create(Payment data);
  Payment delete(String id);
  Payment update(Payment data);
}
