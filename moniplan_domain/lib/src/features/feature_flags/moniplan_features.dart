import 'package:moniplan_domain/moniplan_domain.dart';

extension MoniplanFeatures on FeaturesManager {
  bool isAdvancedAnalyticsEnabled() {
    final key = FeatureKeys.enableAdvancedAnalytics.name;
    final feature = getFeature(key) as EnableAdvancedAnalytics?;
    return feature?.value ?? false;
  }

  bool isAiPredictionsEnabled() {
    final key = FeatureKeys.enableAiPredictions.name;
    final feature = getFeature(key) as EnableAiPredictions?;
    return feature?.value ?? false;
  }

  bool isAutoCategoriesEnabled() {
    final key = FeatureKeys.enableAutoCategories.name;
    final feature = getFeature(key) as EnableAutoCategories?;
    return feature?.value ?? false;
  }
}
