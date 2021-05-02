import 'package:hive/hive.dart';
import 'package:moniplan/sdk/domain.dart';

class BudgetEventAdapter extends TypeAdapter<BudgetEvent> {
  @override
  int get typeId => 0;

  @override
  BudgetEvent read(BinaryReader reader) {
    final data = reader.readMap();
    return BudgetEvent.fromJson(data.cast<String, dynamic>());
  }

  @override
  void write(BinaryWriter writer, BudgetEvent obj) {
    writer.writeMap(obj.toJson());
  }
}
