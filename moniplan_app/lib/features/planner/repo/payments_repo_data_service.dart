import 'package:moniplan_app/core/_index.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

import 'i_payments_repo.dart';

class PaymentsRepoDataService implements IPaymentsRepo {
  PaymentsRepoDataService({required IDataService dataService})
    : _payments = DataServiceCollection<Payment>(
        collection: 'payments',
        dataService: dataService,
        fromJson: Payment.fromJson,
        toJson: (payment) => payment.toJson(),
        idSelector: (payment) => payment.paymentId,
      );

  final IDataServiceCollection<Payment> _payments;

  @override
  Future<List<Payment>> listByPlanner(
    String plannerId, {
    int limit = 5000,
  }) async {
    final response = await _payments.list(
      filter: RecordFilter(equals: {'plannerId': plannerId}),
      options: QueryOptions(limit: limit),
    );
    return response.map((record) => record.data).toList(growable: false);
  }

  @override
  Future<Payment?> getById({
    required String plannerId,
    required String paymentId,
  }) async {
    final record = await _payments.get(paymentId);
    final payment = record?.data;
    if (payment == null || payment.plannerId != plannerId) {
      return null;
    }
    return payment;
  }

  @override
  Future<void> upsert({required String plannerId, required Payment payment}) {
    return _payments.upsert(payment.copyWith(plannerId: plannerId));
  }

  @override
  Future<void> delete({
    required String plannerId,
    required String paymentId,
  }) async {
    final payment = await getById(plannerId: plannerId, paymentId: paymentId);
    if (payment == null) {
      return;
    }
    await _payments.delete(paymentId);
  }

  @override
  Future<void> bulkDelete({
    required String plannerId,
    required List<String> ids,
  }) {
    if (ids.isEmpty) {
      return Future.value();
    }
    // Идемпотентно удаляем по переданному списку id (уже отфильтрованному по планеру)
    return _payments.bulkDelete(ids);
  }

  @override
  Stream<CollectionChange<Payment>> watchChanges() {
    return _payments.watchChanges();
  }
}
