import 'package:moniplan_core/moniplan_core.dart';

final class PaymentsReferenceRepoDrift implements IPaymentsReferenceRepo {
  final MoniplanDriftDb db;

  const PaymentsReferenceRepoDrift({
    required this.db,
  });

  @override
  Future<List<PaymentDetails>> getPaymentsDetailsReference() {
    // TODO: implement getSavedPaymentDetails
    throw UnimplementedError();
  }

  @override
  Future<Set<String>> getAllTags() {
    // TODO: implement getAllTags
    throw UnimplementedError();
  }

  @override
  Future<Set<String>> getAvailableTags() {
    // TODO: implement getAvailableTags
    throw UnimplementedError();
  }
}
