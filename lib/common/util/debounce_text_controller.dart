import 'dart:async';

typedef DebounceTextUpdate = void Function(String newText);

class DebounceText {
  final String name;
  final Duration debounceTimeout;
  final bool Function(String v)? validator;

  StreamController<String> _text = StreamController();
  StreamSubscription<String>? _subscription;
  Timer? _timer;

  String _lastValue = '';
  String get text => _lastValue;
  set text(String newText) {
    _text.sink.add(newText);
    _lastValue = newText;
  }

  bool get isValid {
    if (validator != null) {
      return validator!(text);
    } else {
      return true;
    }
  }

  DebounceText({
    required this.name,
    String? text,
    this.debounceTimeout = Duration.zero,
    this.validator,
  });

  void listenDebounce(DebounceTextUpdate action) {
    _subscription?.cancel();
    _subscription = _text.stream.listen((event) {
      _timer?.cancel();
      _timer = Timer(
        debounceTimeout,
        () => action(text),
      );
    });
  }

  void cancel() {
    _subscription?.cancel();
    _timer?.cancel();
  }

  void dispose() {
    cancel();
    _text.close();
  }
}

extension AdvancedTextEditingList on List<DebounceText> {
  bool get everyValid =>
      map((e) => e.validator?.call(e.text) ?? true).every((e) => e);
}
