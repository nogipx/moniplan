import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_domain/src/_index.dart';

abstract interface class IPaymentsReferenceRepo {
  Future<List<PaymentDetails>> getPaymentsDetailsReference();

  Future<Set<String>> getAvailableTags();

  Future<Set<String>> getAllTags();
}
