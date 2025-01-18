// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

class PaymentBuilder {
  final DateTime _date;

  PaymentDetails? _details;
  DateTimeRepeat? _repeat;
  bool? _isEnabled;
  bool? _isDone;
  DateTime? _start;
  DateTime? _end;

  PaymentBuilder(this._date);

  PaymentBuilder input(String name, [num money = 0]) {
    _details = PaymentDetails(
      name: name,
      money: money,
      type: money <= 0 ? PaymentType.expense : PaymentType.income,
      currency: CurrencyDataCommon.rub,
    );
    return this;
  }

  PaymentBuilder info(PaymentDetails details) {
    _details = details;
    return this;
  }

  PaymentBuilder repeat(DateTimeRepeat repeat) {
    _repeat = repeat;
    return this;
  }

  PaymentBuilder get repeatMonth {
    _repeat = DateTimeRepeat.month;
    return this;
  }

  PaymentBuilder get enabled {
    _isEnabled = true;
    return this;
  }

  PaymentBuilder get disabled {
    _isEnabled = false;
    return this;
  }

  PaymentBuilder get done {
    _isDone = true;
    return this;
  }

  PaymentBuilder start(DateTime data) {
    _start = data;
    return this;
  }

  PaymentBuilder end(DateTime data) {
    _end = data;
    return this;
  }

  Payment build() {
    if (_details == null) {
      throw Exception('Details and repeat must be set');
    }
    return Payment(
      paymentId: const Uuid().v4(),
      details: _details!,
      date: _date,
      repeat: _repeat ?? DateTimeRepeat.noRepeat,
      isDone: _isDone ?? false,
      isEnabled: _isEnabled ?? true,
      dateStart: _start,
      dateEnd: _end,
    );
  }
}

extension PaymentStringExtension on String {
  PaymentBuilder get p {
    return PaymentBuilder(date);
  }

  DateTime get date {
    final dateParts = split('.');
    final pYear = int.tryParse(dateParts.elementAtOrNull(2) ?? '');
    final pMonth = int.tryParse(dateParts.elementAtOrNull(1) ?? '');
    final pDay = int.tryParse(dateParts.elementAtOrNull(0) ?? '');

    final now = DateTime.now();

    final isValidInput = switch (dateParts.length) {
      0 => false,
      1 => pDay != null,
      2 => pDay != null && pMonth != null,
      3 => pDay != null && pMonth != null && pYear != null,
      _ => false,
    };

    if (!isValidInput) {
      throw FormatException('Invalid date format');
    }

    final date = switch (dateParts.length) {
      0 => throw FormatException('Invalid date format'),
      1 => DateTime(now.year, now.month, pDay!),
      2 => DateTime(now.year, pMonth!, pDay!),
      3 => DateTime(pYear!, pMonth!, pDay!),
      _ => throw FormatException('Date should be in format "dd.mm.yyyy"'),
    };

    return date;
  }
}
