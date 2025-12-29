import 'backup_footer_metadata.dart';

class BackupInfo {
  final String token;
  final DateTime? creationDate;
  final BackupFooterMetadata? metadata;

  BackupInfo({
    required this.token,
    required this.creationDate,
    this.metadata,
  });
}
