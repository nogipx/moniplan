import 'package:moniplan_app/core/_index.dart';

/// Работа только с коллекцией настроек планнера.
abstract interface class IPlannerSettingsRepo {
  Future<PlannerSettings?> getSettings();

  Future<void> saveSettings(PlannerSettings settings);

  Future<void> deleteSettings();

  PlannerSettings createDefaultSettings();
}
