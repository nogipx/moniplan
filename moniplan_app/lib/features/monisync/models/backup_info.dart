import 'backup_footer_metadata.dart';

class BackupInfo {
  final String token;
  final DateTime? creationDate;
  final int plannersCount;
  final BackupFooterMetadata? metadata;

  BackupInfo({
    required this.token,
    required this.creationDate,
    required this.plannersCount,
    this.metadata,
  });
}
