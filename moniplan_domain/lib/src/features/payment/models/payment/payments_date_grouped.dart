// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

class PaymentsDateGrouped {
  final DateTime date;
  final List<Payment> payments;

  const PaymentsDateGrouped({
    required this.date,
    required this.payments,
  });
}
