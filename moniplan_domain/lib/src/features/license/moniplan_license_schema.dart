import 'package:moniplan_domain/moniplan_domain.dart';

final moniplanLicenseSchema = LicenseSchema(
  featureSchema: {
    'feature_statistics': SchemaField(type: FieldType.boolean, required: true),
    'feature_insights': SchemaField(type: FieldType.boolean, required: true),
    'feature_monisync': SchemaField(type: FieldType.boolean, required: true),
    'feature_ai': SchemaField(type: FieldType.boolean, required: true),
    'limit_repeated_payments': SchemaField(type: FieldType.boolean),
    'limit_max_planners': SchemaField(
      type: FieldType.number,
      validators: [NumberValidator(minimum: 1, maximum: 10)],
    ),
  },
  metadataSchema: {
    'user_info_hash': SchemaField(type: FieldType.string, required: true),
    'device_hash': SchemaField(type: FieldType.string, required: true),
  },
);
