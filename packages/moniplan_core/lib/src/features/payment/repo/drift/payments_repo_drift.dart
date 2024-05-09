import 'package:moniplan_core/moniplan_core.dart';

final class PaymentsRepoDrift implements IPaymentsRepo {
  @override
  Future<Payment?> getById({required String plannerId, required String paymentId}) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<Payment?> save({required String plannerId, required Payment payment}) {
    // TODO: implement save
    throw UnimplementedError();
  }

  @override
  Future<void> setDoneState(
      {required String plannerId, required String paymentId, required bool isDone}) {
    // TODO: implement setDoneState
    throw UnimplementedError();
  }

  @override
  Future<void> setEnabledState(
      {required String plannerId, required String paymentId, required bool isEnabled}) {
    // TODO: implement setEnabledState
    throw UnimplementedError();
  }
}
