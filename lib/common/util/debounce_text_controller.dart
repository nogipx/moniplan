import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';

class AdvancedTextEditingController extends TextEditingController {
  final String name;
  final Duration debounceTimeout;
  final bool Function(String v)? validator;

  AdvancedTextEditingController({
    required this.name,
    String? text,
    this.debounceTimeout = const Duration(milliseconds: 250),
    this.validator,
  }) : super(text: text);

  @override
  void dispose() {
    cancelDebounce();
    super.dispose();
  }

  bool get isValid {
    if (validator != null) {
      return validator!(text);
    } else {
      throw ArgumentError.notNull('validator');
    }
  }

  void createDebounce(VoidCallback action) {
    EasyDebounce.debounce(name, debounceTimeout, action);
  }

  void cancelDebounce() => EasyDebounce.cancel(name);
}

extension AdvancedTextEditingList on List<AdvancedTextEditingController> {
  bool get everyValid =>
      map((e) => e.validator?.call(e.text) ?? true).every((e) => e);
}
