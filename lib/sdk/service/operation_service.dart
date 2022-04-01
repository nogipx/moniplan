import 'package:moniplan/sdk/domain.dart';

abstract class OperationService {
  static const String key = 'operationService';

  List<Operation> getAll();
  Future<void> save(Operation event);
  Future<void> delete(Operation event);
}
