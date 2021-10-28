import 'package:hive/hive.dart';
import 'package:moniplan/sdk/domain.dart';

class OperationAdapter extends TypeAdapter<Operation> {
  @override
  int get typeId => 1;

  static const _mapping = <int, String>{
    0: 'id',
    1: 'expectedValue',
    2: 'actualValue',
    3: 'reason',
    4: 'enabled',
    5: 'currency',
    6: 'date',
  };

  @override
  Operation read(BinaryReader reader) {
    final data = reader.readMap();
    try {
      final _data = _mapping.map<String, dynamic>((intKey, stringKey) {
        return MapEntry<String, dynamic>(
          stringKey,
          data[intKey] ?? data[stringKey],
        );
      });
      return Operation.fromJson(_data);
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      return Operation.stub;
    }
  }

  @override
  void write(BinaryWriter writer, Operation obj) {
    final json = obj.toJson();
    final _map = _mapping.map<int, dynamic>((intKey, stringKey) {
      return MapEntry<int, dynamic>(intKey, json[stringKey]);
    });
    writer.writeMap(_map);
  }
}
