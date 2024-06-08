import 'package:moniplan_core/moniplan_core.dart';

final class PaymentsRepoDrift implements IPaymentsReferenceRepo {
  final MoniplanDriftDb db;

  const PaymentsRepoDrift({
    required this.db,
  });
}
