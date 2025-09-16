import 'package:moniplan_app/core/_index.dart';

typedef CheckPaymentCanApplyUpdateResult = ({bool canUpdate, Set<String> errorKeys});

class CheckPaymentCanApplyUpdate {
  final Payment updatedPayment;

  const CheckPaymentCanApplyUpdate({required this.updatedPayment});

  CheckPaymentCanApplyUpdateResult run() {
    final errorKeys = <String>[];

    if (updatedPayment.isRepeat && updatedPayment.isDone) {
      errorKeys.add('doneWithRepeat');
    }

    if (updatedPayment.date == DateTime(0)) {
      errorKeys.add('requiredDate');
    }

    return (canUpdate: !errorKeys.contains('requiredDate'), errorKeys: errorKeys.toSet());
  }
}
