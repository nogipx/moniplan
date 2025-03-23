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

  LicenseValidateUseCase get _validateUseCase =>
      LicenseValidateUseCase(validator: _licenseValidator, schema: moniplanLicenseSchema);

  @override
  Future<License?> getCurrentLicense() async {
    final license = await _licenseRepository.getCurrentLicense();

    return license;
  }

  @override
  Future<LicenseStatus> getLicenseStatus({License? license}) async {
    if (license != null) {
      return _validateUseCase(license);
    }
    final currentLicense = await getCurrentLicense();
    final status = await _validateUseCase(currentLicense);
    return status;
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
    final licenseJson = LicenseEncoder.decodeFromBytes(licenseBytes);
    if (licenseJson == null) {
      return null;
    }

    final licenseModel = LicenseModel.fromJson(licenseJson);
    return licenseModel.toDomain();
  }
}
