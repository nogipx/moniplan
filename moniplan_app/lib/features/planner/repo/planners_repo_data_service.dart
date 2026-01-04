import 'package:moniplan_app/core/_index.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

import 'i_planners_repo.dart';

class PlannersRepoDataService implements IPlannersRepo {
  PlannersRepoDataService({required IDataService dataService})
    : _planners = DataServiceCollection<Planner>(
        collection: 'planners',
        dataService: dataService,
        fromJson: Planner.fromJson,
        toJson: (planner) => planner.copyWith(payments: [], actualInfo: null).toJson(),
        idSelector: (planner) => planner.id,
      );

  final IDataServiceCollection<Planner> _planners;

  @override
  Future<List<Planner>> list({int limit = 1000}) async {
    final response = await _planners.list(options: QueryOptions(limit: limit));
    return response.map((record) => record.data).toList(growable: false);
  }

  @override
  Future<Planner?> getById(String id) async {
    final record = await _planners.get(id);
    return record?.data;
  }

  @override
  Future<void> upsert(Planner planner) {
    return _planners.upsert(planner);
  }

  @override
  Future<void> delete(String id) {
    return _planners.delete(id);
  }
}
