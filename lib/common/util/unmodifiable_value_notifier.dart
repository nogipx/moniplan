import 'package:flutter/material.dart';

class UnmodifiableValueNotifier<T> extends ValueNotifier<T> {
  UnmodifiableValueNotifier(T value) : super(value);

  @override
  set value(T newValue) {}
}

extension ValueNotifierExt<T> on ValueNotifier<T> {
  UnmodifiableValueNotifier get unmodifiable =>
      UnmodifiableValueNotifier<T>(value);
}
