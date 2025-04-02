import 'dart:typed_data';

import 'package:moniplan_app/features/license/_index.dart';
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
  Future<LicenseStatusResult> getLicenseStatus({License? license}) async {
    final effectiveLicense = license ?? await getCurrentLicense();
    if (effectiveLicense == null) {
      return (status: NoLicenseStatus(), license: effectiveLicense);
    }

    if (!_licenseValidator.validateSignature(effectiveLicense).isValid) {
      return (status: InvalidLicenseSignatureStatus(), license: effectiveLicense);
    }

    if (!_licenseValidator.validateExpiration(effectiveLicense).isValid) {
      return (status: ExpiredLicenseStatus(effectiveLicense), license: effectiveLicense);
    }

    final schema = moniplanLicenseSchema;
    final schemaResult = _licenseValidator.validateSchema(effectiveLicense, schema);
    if (!schemaResult.isValid) {
      return (status: InvalidLicenseSchemaStatus(schemaResult), license: effectiveLicense);
    }

    return (status: ActiveLicenseStatus(effectiveLicense), license: effectiveLicense);
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
    final license = LicenseEncoder.decode(licenseBytes);
    return license;
  }
}
