import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:moniplan_core/moniplan_core.dart';

abstract class OperationDataSource {
  IList<Operation> getAll();
  Operation getById(String id);
  Operation create(Operation data);
  Operation delete(String id);
  Operation update(Operation data);
}
