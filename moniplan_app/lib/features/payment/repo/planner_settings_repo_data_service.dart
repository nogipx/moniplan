import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/database/data_collection.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

import 'i_planner_settings_repo.dart';

class PlannerSettingsRepoDataService implements IPlannerSettingsRepo {
  PlannerSettingsRepoDataService({required IDataService dataService})
    : _settings = DataCollection<PlannerSettings>(
        collection: 'planner_settings',
        dataService: dataService,
        fromJson: PlannerSettings.fromJson,
        toJson: (settings) => settings.toJson(),
        idSelector: (settings) => settings.id,
      );

  final DataCollection<PlannerSettings> _settings;
  static const _settingsId = 'current';

  @override
  Future<PlannerSettings?> getSettings() async {
    final record = await _settings.get(_settingsId);
    return record?.data;
  }

  @override
  Future<void> saveSettings(PlannerSettings settings) {
    return _settings.upsert(settings);
  }

  @override
  Future<void> deleteSettings() {
    return _settings.delete(_settingsId);
  }

  @override
  PlannerSettings createDefaultSettings() {
    return const PlannerSettings(id: _settingsId);
  }
}
