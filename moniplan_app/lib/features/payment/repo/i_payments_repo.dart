import 'package:moniplan_app/core/_index.dart';

/// Работа только с коллекцией платежей в рамках конкретного планера.
abstract interface class IPaymentsRepo {
  Future<List<Payment>> listByPlanner(String plannerId, {int limit});

  Future<Payment?> getById({
    required String plannerId,
    required String paymentId,
  });

  Future<void> upsert({required String plannerId, required Payment payment});

  Future<void> delete({required String plannerId, required String paymentId});

  Future<void> bulkDelete({
    required String plannerId,
    required List<String> ids,
  });
}
