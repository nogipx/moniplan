import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_domain/src/_index.dart';

abstract interface class IPaymentsRepo {
  Future<void> setEnabledState({
    required String plannerId,
    required String paymentId,
    required bool isEnabled,
  });

  Future<void> setDoneState({
    required String plannerId,
    required String paymentId,
    required bool isDone,
  });

  Future<Payment?> getById({
    required String plannerId,
    required String paymentId,
  });

  Future<Payment?> save({
    required String plannerId,
    required Payment payment,
  });
}
