import 'package:moniplan_domain/moniplan_domain.dart';

import 'package:moniplan_core/src/features/payment_reference/repo/mock/_details.dart';
import 'package:moniplan_core/src/features/payment_reference/repo/mock/_tags.dart';

class MockPaymentsReferenceRepo implements IPaymentsReferenceRepo {
  @override
  Future<List<PaymentDetails>> getPaymentsDetailsReference() async {
    return D.list;
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
