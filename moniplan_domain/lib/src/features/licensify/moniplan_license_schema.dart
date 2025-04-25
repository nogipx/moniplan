import 'package:moniplan_domain/moniplan_domain.dart';

final moniplanLicenseSchema = _getLicenseSchema();

abstract interface class MoniplanLicenseKeys {
  static const metadataDeviceHash = 'deviceHash';
}

/// Определение схемы лицензии для проверки
LicenseSchema? _getLicenseSchema() {
  return LicenseSchema(
    metadataSchema: {
      MoniplanLicenseKeys.metadataDeviceHash: SchemaField(type: FieldType.string, required: true),
    },
    allowUnknownFeatures: true,
    allowUnknownMetadata: true,
  );
}
