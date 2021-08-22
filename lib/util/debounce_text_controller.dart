import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';

class DebounceTextEditingController extends TextEditingController {
  final String name;
  final Duration debounceTimeout;

  DebounceTextEditingController({
    required this.name,
    String? text,
    this.debounceTimeout = const Duration(milliseconds: 500),
  }) : super(text: text);

  @override
  void dispose() {
    cancelDebounce();
    super.dispose();
  }

  void createDebounce(VoidCallback action) {
    EasyDebounce.debounce(name, debounceTimeout, action);
  }

  void cancelDebounce() => EasyDebounce.cancel(name);
}
