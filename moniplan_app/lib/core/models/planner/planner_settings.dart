import 'package:freezed_annotation/freezed_annotation.dart';

part 'planner_settings.freezed.dart';
part 'planner_settings.g.dart';

@Freezed()
abstract class PlannerSettings with _$PlannerSettings {
  const factory PlannerSettings({
    required String id,
    String? currentPlannerId,
  }) = _PlannerSettings;

  factory PlannerSettings.fromJson(Map<String, dynamic> json) =>
      _$PlannerSettingsFromJson(json);
}
