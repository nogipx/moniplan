import 'package:flutter/material.dart';

/// Абстрактный класс набора радиусов для ui kit
abstract class AppRadius {
  static const Radius r0 = Radius.zero;
  static const Radius r2 = Radius.circular(2.0);
  static const Radius r4 = Radius.circular(4.0);
  static const Radius r6 = Radius.circular(6.0);
  static const Radius r8 = Radius.circular(8.0);
  static const Radius r10 = Radius.circular(10.0);
  static const Radius r12 = Radius.circular(12.0);
  static const Radius r16 = Radius.circular(16.0);
  static const Radius r20 = Radius.circular(20.0);
  static const Radius r24 = Radius.circular(24.0);
  static const Radius r28 = Radius.circular(28.0);
  static const Radius r32 = Radius.circular(32.0);
  static const Radius r50 = Radius.circular(50.0);
}

extension RadiusExt on Radius {
  double get value => x;
}
