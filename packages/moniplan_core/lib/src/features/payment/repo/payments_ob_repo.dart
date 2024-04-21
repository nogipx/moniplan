import 'package:moniplan_core/moniplan_core.dart';

class PaymentsRepo implements IPaymentsRepo {
  final Store store;

  const PaymentsRepo({
    required this.store,
  });

  Box<PaymentComposedDaoOB> get _paymentsBox => store.box<PaymentComposedDaoOB>();

  static const _paymentMapper = PaymentMapperOB();

  @override
  Future<void> setDoneState({
    required String plannerId,
    required String paymentId,
    required bool isDone,
  }) async {
    final payment = await getById(
      plannerId: plannerId,
      paymentId: paymentId,
    );

    if (payment != null) {
      final updated = payment.copyWith(
        isDone: isDone,
      );
      final dao = _paymentMapper.toDto(updated);

      await _paymentsBox.putAsync(
        dao,
        mode: PutMode.update,
      );
    }
  }

  @override
  Future<void> setEnabledState({
    required String plannerId,
    required String paymentId,
    required bool isEnabled,
  }) async {
    final payment = await getById(
      plannerId: plannerId,
      paymentId: paymentId,
    );

    if (payment != null) {
      final updated = payment.copyWith(
        isEnabled: isEnabled,
      );
      final dao = _paymentMapper.toDto(updated);
      await _paymentsBox.putAsync(
        dao,
        mode: PutMode.update,
      );
    }
  }

  @override
  Future<Payment?> getById({
    required String plannerId,
    required String paymentId,
  }) async {
    final paymentDao =
        _paymentsBox.query(PaymentComposedDaoOB_.paymentId.equals(paymentId)).build().findUnique();

    if (paymentDao != null) {
      return _paymentMapper.toDomain(paymentDao);
    }

    return null;
  }

  @override
  Future<Payment?> save({
    required String plannerId,
    required Payment payment,
  }) {
    // TODO: implement save
    throw UnimplementedError();
  }
}
