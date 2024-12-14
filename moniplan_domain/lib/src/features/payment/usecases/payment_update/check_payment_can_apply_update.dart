import 'package:moniplan_domain/moniplan_domain.dart';

typedef CheckPaymentCanApplyUpdateResult = ({bool canUpdate, Set<String> errorKeys});

class CheckPaymentCanApplyUpdate implements IUseCase<CheckPaymentCanApplyUpdateResult> {
  final Payment updatedPayment;

  const CheckPaymentCanApplyUpdate({required this.updatedPayment});

  @override
  CheckPaymentCanApplyUpdateResult run() {
    final errorKeys = <String>[];

    if (updatedPayment.isRepeat && updatedPayment.isDone) {
      errorKeys.add(MoniplanKeys.i.payments.error.doneWithRepeat);
    }

    if (updatedPayment.date == DateTime(0)) {
      errorKeys.add(MoniplanKeys.i.payments.error.requiredDate);
    }

    return (
      canUpdate: !errorKeys.contains(MoniplanKeys.i.payments.error.requiredDate),
      errorKeys: errorKeys.toSet(),
    );
  }
}
