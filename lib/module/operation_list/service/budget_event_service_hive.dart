import 'package:hive/hive.dart';
import 'package:moniplan/sdk/domain.dart';

class OperationServiceHive implements OperationService {
  final Box<Operation> hive;

  OperationServiceHive({required this.hive});

  @override
  Future<void> delete(Operation event) async {
    return hive.delete(event.id);
  }

  @override
  List<Operation> getAll() {
    final data = hive.toMap();
    return data.values.toList();
  }

  @override
  Future<void> save(Operation event) async {
    return hive.put(event.id, event);
  }
}
