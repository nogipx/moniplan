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
