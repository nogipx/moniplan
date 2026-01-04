import 'package:moniplan_app/core/_index.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

import 'i_planner_actual_info_repo.dart';

class PlannerActualInfoRepoDataService implements IPlannerActualInfoRepo {
  PlannerActualInfoRepoDataService({required IDataService dataService})
    : _actualInfo = DataServiceCollection<PlannerActualInfo>(
        collection: 'planner_actual_info',
        dataService: dataService,
        fromJson: PlannerActualInfo.fromJson,
        toJson: (info) => info.toJson(),
        idSelector: (info) => info.plannerId,
      );

  final IDataServiceCollection<PlannerActualInfo> _actualInfo;

  @override
  Future<PlannerActualInfo?> get(String plannerId) async {
    final record = await _actualInfo.get(plannerId);
    return record?.data;
  }

  @override
  Future<void> upsert(PlannerActualInfo actualInfo) {
    return _actualInfo.upsert(actualInfo);
  }

  @override
  Future<void> delete(String plannerId) {
    return _actualInfo.delete(plannerId);
  }
}
