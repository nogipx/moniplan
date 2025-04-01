import 'dart:typed_data';

import 'package:licensify/licensify.dart';

typedef LicenseStatusResult = ({License? license, LicenseStatus status});

abstract class IMoniplanLicenseRepo {
  Future<License?> getCurrentLicense();

  Future<void> saveLicense(License license);

  Future<void> removeLicense();

  Future<LicenseStatusResult> getLicenseStatus({License? license});

  Future<License?> decodeLicense({Uint8List? licenseBytes});
}
