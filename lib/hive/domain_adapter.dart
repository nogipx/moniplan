import 'package:hive/hive.dart';
import 'package:moniplan/sdk/domain.dart';

class BudgetEventAdapter extends TypeAdapter<BudgetPrediction> {
  @override
  int get typeId => 0;

  @override
  BudgetPrediction read(BinaryReader reader) {
    final data = reader.readMap();
    return BudgetPrediction.fromJson(data.cast<String, dynamic>());
  }

  @override
  void write(BinaryWriter writer, BudgetPrediction obj) {
    writer.writeMap(obj.toJson());
  }
}

class OperationAdapter extends TypeAdapter<Operation> {
  @override
  int get typeId => 1;

  @override
  Operation read(BinaryReader reader) {
    final data = reader.readMap();
    return Operation.fromJson(data.cast<String, dynamic>());
  }

  @override
  void write(BinaryWriter writer, Operation obj) {
    writer.writeMap(obj.toJson());
  }
}
