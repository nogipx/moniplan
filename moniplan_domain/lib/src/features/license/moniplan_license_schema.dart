import 'package:moniplan_domain/moniplan_domain.dart';

final moniplanLicenseSchema = _getLicenseSchema();

abstract interface class MoniplanLicenseKeys {
  static const featureMonisyncBackupPassword = 'monisyncBackupPassword';
  static const featureMonisyncExportData = 'monisyncExportData';
  static const featureAnalyticsInsights = 'analyticsInsights';
  static const featurePlannerAllowMany = 'plannerAllowMany';
  static const metadataDeviceHash = 'deviceHash';
  static const metadataIssueHash = 'issueHash';
  static const metadataTelegramUsername = 'telegramUsername';
}

/// Определение схемы лицензии для проверки
LicenseSchema? _getLicenseSchema() {
  return null;
  return LicenseSchema(
    featureSchema: {
      MoniplanLicenseKeys.featureMonisyncBackupPassword: SchemaField(
        type: FieldType.boolean,
        required: false,
      ),
      MoniplanLicenseKeys.featureMonisyncExportData: SchemaField(
        type: FieldType.boolean,
        required: false,
      ),
      MoniplanLicenseKeys.featureAnalyticsInsights: SchemaField(
        type: FieldType.boolean,
        required: false,
      ),
      MoniplanLicenseKeys.featurePlannerAllowMany: SchemaField(
        type: FieldType.boolean,
        required: false,
      ),
    },
    metadataSchema: {
      MoniplanLicenseKeys.metadataDeviceHash: SchemaField(type: FieldType.string, required: true),
      MoniplanLicenseKeys.metadataIssueHash: SchemaField(type: FieldType.string, required: true),
      MoniplanLicenseKeys.metadataTelegramUsername: SchemaField(type: FieldType.string),
    },
    allowUnknownFeatures: true,
    allowUnknownMetadata: true,
  );
}
