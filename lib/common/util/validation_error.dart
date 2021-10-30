import 'package:flutter/cupertino.dart';

extension ErrorsList<T extends ValidationError> on Iterable<T> {
  List<T> get globals => List.unmodifiable(
      where((e) => e.key.contains(ValidationError.defaultKey)));

  ValidationError? getByKey(String key) {
    final found = where((e) => e.key == key);
    return found.isNotEmpty ? found.first : null;
  }

  ValidationError? getByField(TextEditingController controller) {
    final found = where((e) => e.key == controller.hashCode.toString());
    return found.isNotEmpty ? found.first : null;
  }
}

class ValidationError {
  final String key;
  final String msg;
  const ValidationError({
    required this.msg,
    this.key = defaultKey,
  });

  static const String defaultKey = '@global';
}

class TextFieldValidationError extends ValidationError {
  TextFieldValidationError({
    required String msg,
    required TextEditingController controller,
  }) : super(msg: msg, key: controller.hashCode.toString());
}
