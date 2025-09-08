// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_app/domain/moniplan_domain.dart';

typedef CheckPaymentCanApplyUpdateResult = ({bool canUpdate, Set<String> errorKeys});

class CheckPaymentCanApplyUpdate implements IUseCase<CheckPaymentCanApplyUpdateResult> {
  final Payment updatedPayment;

  const CheckPaymentCanApplyUpdate({required this.updatedPayment});

  @override
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
