import 'package:moniplan/sdk/domain.dart';
import 'package:hive/hive.dart';

class OperationServiceHive implements OperationService {
  final Box<Operation> hive;

  OperationServiceHive({required this.hive});

  @override
  Future<void> delete(Operation event) async {
    hive.delete(event.id);
  }

  @override
  List<Operation> getAll() {
    final data = hive.toMap();
    return data.values.toList();
  }

  @override
  Future<void> save(Operation event) async {
    hive.put(event.id, event);
  }
}
