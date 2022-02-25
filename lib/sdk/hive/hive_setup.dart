import 'package:hive_flutter/hive_flutter.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/sdk/hive/currency_adapter.dart';

abstract class HiveBoxes {
  static const String tripList = 'tripList';
}

class HiveInstance {
  Future<void> init() async {
    if (!_initialized) {
      _initialized = true;
      await Hive.initFlutter();
      _registerAdapters();
    }
  }

  static bool _initialized = false;
  static final Map<String, Box> _boxes = {};

  Future<Box<T>> openBox<T>(String name) async {
    if (_boxes.containsKey(name)) {
      final _box = _boxes[name]!;
      if (_box.isOpen && _box.runtimeType is Box<T>) {
        return _box as Box<T>;
      }
    }
    final box = await Hive.openBox<T>(name);
    _boxes[name] = box;
    return box;
  }

  void _registerAdapters() {}
}
