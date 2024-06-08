import 'package:moniplan_domain/moniplan_domain.dart';

import '_details.dart';
import '_tags.dart';

class MockPaymentsReferenceRepo implements IPaymentsReferenceRepo {
  @override
  Future<List<PaymentDetails>> getPaymentsDetailsReference() async {
    return Details.list;
  }

  @override
  Future<Set<String>> getAllTags() async {
    return Tags.all;
  }

  @override
  Future<Set<String>> getAvailableTags() async {
    return Tags.all;
  }
}
