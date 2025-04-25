import 'dart:typed_data';

import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MoniplanLicenseRepository implements IMoniplanLicenseRepo {
  final ILicenseRepository _licenseRepository;
  final ILicenseValidator _licenseValidator;
  final ILicenseRequestGenerator _licenseRequestGenerator;
  final IDeviceHashGenerator _deviceHashGenerator;

  MoniplanLicenseRepository({
    required ILicenseStorage licenseStorage,
    required ILicenseValidator licenseValidator,
    required ILicenseRequestGenerator licenseRequestGenerator,
    required IDeviceHashGenerator deviceHashGenerator,
  }) : _licenseRepository = LicenseRepository(storage: licenseStorage),
       _licenseValidator = licenseValidator,
       _licenseRequestGenerator = licenseRequestGenerator,
       _deviceHashGenerator = deviceHashGenerator;

  @override
  Future<License?> getCurrentLicense() async {
    final license = await _licenseRepository.getCurrentLicense();

    return license;
  }

  @override
  Future<LicenseStatus> getLicenseStatus({License? license}) async {
    final effectiveLicense = license ?? await getCurrentLicense();
    final getLicenseStatusUseCase = GetLicenseStatusUseCase(
      licenseValidator: _licenseValidator,
      deviceHashGenerator: _deviceHashGenerator,
    );

    return getLicenseStatusUseCase.call(effectiveLicense);
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

  @override
  Future<Uint8List> generateLicenseRequest({int expirationHours = 48}) async {
    final deviceHash = await _deviceHashGenerator();

    // Получение идентификатора приложения
    final packageInfo = await PackageInfo.fromPlatform();
    final appId = packageInfo.packageName;

    // Генерация запроса лицензии
    final requestData = _licenseRequestGenerator(
      deviceHash: deviceHash,
      appId: appId,
      expirationHours: expirationHours,
    );

    return requestData;
  }
}
