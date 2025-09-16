import 'dart:convert';

import 'package:drift/drift.dart';

class DriftListStringConverter extends TypeConverter<List<String>, String> {
  @override
  List<String> fromSql(String fromDb) {
    return List<String>.from(json.decode(fromDb));
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

class DriftSetStringConverter extends TypeConverter<Set<String>, String> {
  const DriftSetStringConverter();

  @override
  Set<String> fromSql(String fromDb) {
    final set = Set<String>.from(fromDb.split('|'));
    return set;
  }

  @override
  String toSql(Set<String> value) {
    final data = value.join('|');
    return json.encode(data);
  }
}
