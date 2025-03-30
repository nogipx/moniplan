import 'dart:convert';
import 'dart:typed_data';

import 'package:moniplan_domain/moniplan_domain.dart';

class MoniplanLicenseRepository implements IMoniplanLicenseRepo {
  final ILicenseRepository _licenseRepository;
  final ILicenseValidator _licenseValidator;

  MoniplanLicenseRepository({
    required ILicenseStorage licenseStorage,
    required ILicenseValidator licenseValidator,
  }) : _licenseRepository = LicenseRepository(storage: licenseStorage),
       _licenseValidator = licenseValidator;

  @override
  Future<License?> getCurrentLicense() async {
    final license = await _licenseRepository.getCurrentLicense();

    return license;
  }

  @override
  Future<LicenseStatus> getLicenseStatus({License? license}) async {
    final effectiveLicense = license ?? await getCurrentLicense();
    if (effectiveLicense == null) {
      return NoLicenseStatus();
    }

    if (!_licenseValidator.validateSignature(effectiveLicense).isValid) {
      return InvalidLicenseSignatureStatus();
    }

    if (!_licenseValidator.validateExpiration(effectiveLicense).isValid) {
      return ExpiredLicenseStatus(effectiveLicense);
    }

    final schema = _getLicenseSchema();
    final schemaResult = _licenseValidator.validateSchema(effectiveLicense, schema);
    if (!schemaResult.isValid) {
      return InvalidLicenseSchemaStatus(schemaResult);
    }

    return ActiveLicenseStatus(effectiveLicense);
  }

  @override
  Future<void> removeLicense() async {
    await _licenseRepository.removeLicense();
  }

  @override
  Future<void> saveLicense(license) async {
    await _licenseRepository.saveLicense(license);
  }

  @override
  Future<License?> decodeLicense({Uint8List? licenseBytes}) async {
    if (licenseBytes == null) {
      return null;
    }
    final license = LicenseEncoder.decodeFromBytes(licenseBytes);
    return license;
  }
}

/// Определение схемы лицензии для проверки
LicenseSchema _getLicenseSchema() {
  return LicenseSchema(
    featureSchema: {
      'monisync': SchemaField(type: FieldType.boolean, required: true),
      'analytics': SchemaField(type: FieldType.boolean, required: true),
    },
    metadataSchema: {
      'user_hash': SchemaField(type: FieldType.string, required: true),
      'issuer_id': SchemaField(type: FieldType.string, required: true),
      'device_hash': SchemaField(type: FieldType.string, required: true),
    },
    allowUnknownFeatures: true,
    allowUnknownMetadata: true,
  );
}
