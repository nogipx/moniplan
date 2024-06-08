import 'package:moniplan_domain/moniplan_domain.dart';

import '_details.dart';

class MockPaymentsReferenceRepo implements IPaymentsReferenceRepo {
  @override
  Future<List<PaymentDetails>> getPaymentsDetailsReference() async {
    return Details.list;
  }
}
