// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

@Deprecated('Чтобы не потерять старые цвета, не исопльзовать в проде')
abstract interface class ExperimentColor {
  static const moniplanBrand = Color(0xff0C82D8);
  static const paynesGray = Color(0xff4F5D75);
  static const eerieBlack = Color(0xff1E1B18);
  static const night = Color(0xff12130F);
  static const platinum = Color(0xffEAE6E5);
  static const jet = Color(0xff333333);
  static const antiFlashWhite = Color(0xffEFF1F3);
  static final lightBrandColor = const Color(0xff58A9E4);
  static const orangeColor = Color(0xffD9860D);
  static const lightOrangeColor = Color(0xffE3AB59);
  static const disabledColor = Color(0xff9299A2);
  static const positiveMoneyColor = Color(0xff3C8900);
  static const negativeMoneyColor = Color(0xffDF0000);
  static const darkBackgroundColor = Color(0xff5b5a5a);
  static const green = Colors.green;
  static const daySeparatorBackground = ExperimentColor.eerieBlack;
  static const primaryTextColor = Color(0xff454545);
  static const secondaryTextColor = Color(0xff9299A2);
  static const inactiveBackgroundColor = Color(0xffF4F4F4);
  static const inactiveTextColor = Color(0xffC7C9CC);
  static const navigationBarColor = Color(0xffC7C9CC);
}
