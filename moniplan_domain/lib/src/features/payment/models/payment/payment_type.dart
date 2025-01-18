// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

enum PaymentType {
  unknown(-100, 0),
  income(1, 1),
  expense(-1, 2);

  final double modifier;
  final int id;

  const PaymentType(this.modifier, this.id);

  static from(int? id) {
    return switch (id) {
      0 => PaymentType.unknown,
      1 => PaymentType.income,
      2 => PaymentType.expense,
      _ => PaymentType.unknown,
    };
  }
}
