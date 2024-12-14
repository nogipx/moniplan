import 'package:moniplan_domain/moniplan_domain.dart';

typedef CheckPaymentCanApplyUpdateResult = ({bool canUpdate, String errorKey});

class CheckPaymentCanApplyUpdate implements IUseCase<CheckPaymentCanApplyUpdateResult> {
  final Payment updatedPayment;

  const CheckPaymentCanApplyUpdate({required this.updatedPayment});

  @override
  CheckPaymentCanApplyUpdateResult run() {
    if (updatedPayment.isRepeat && updatedPayment.isDone) {
      return (
        canUpdate: false,
        errorKey: MoniplanKeys.i.payments.error.doneWithRepeat,
      );
    }

    return (canUpdate: true, errorKey: '');
  }
}
