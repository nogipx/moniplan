import 'dart:typed_data';

import 'package:licensify/licensify.dart';

abstract class IMoniplanLicenseRepo {
  Future<License?> getCurrentLicense();

  Future<void> saveLicense(License license);

  Future<void> removeLicense();

  Future<LicenseStatus> getLicenseStatus({License? license});

  Future<License?> decodeLicense({Uint8List? licenseBytes});

  Future<Uint8List> generateLicenseRequest();
}

class MockLicenseRepository implements IMoniplanLicenseRepo {
  @override
  Future<License?> decodeLicense({Uint8List? licenseBytes}) {
    // TODO: implement decodeLicense
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> generateLicenseRequest() {
    // TODO: implement generateLicenseRequest
    throw UnimplementedError();
  }

  @override
  Future<License?> getCurrentLicense() {
    // TODO: implement getCurrentLicense
    throw UnimplementedError();
  }

  @override
  Future<LicenseStatus> getLicenseStatus({License? license}) {
    // TODO: implement getLicenseStatus
    throw UnimplementedError();
  }

  @override
  Future<void> removeLicense() {
    // TODO: implement removeLicense
    throw UnimplementedError();
  }

  @override
  Future<void> saveLicense(License license) {
    // TODO: implement saveLicense
    throw UnimplementedError();
  }
}
