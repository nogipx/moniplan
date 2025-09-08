// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_footer_metadata.freezed.dart';
part 'backup_footer_metadata.g.dart';

/// Метаданные, хранящиеся в footer PASETO токена
@freezed
class BackupFooterMetadata with _$BackupFooterMetadata {
  const factory BackupFooterMetadata({
    /// Временная метка создания бэкапа
    required DateTime timestamp,

    /// Тип бэкапа
    @Default('monisync_backup') String type,

    /// Версия формата бэкапа
    @Default('2.0') String version,
  }) = _BackupFooterMetadata;

  const BackupFooterMetadata._();

  factory BackupFooterMetadata.fromJson(Map<String, dynamic> json) =>
      _$BackupFooterMetadataFromJson(json);

  /// Создает строку footer для PASETO токена
  String toFooter() => json.encode(toJson());

  /// Создает метаданные из footer PASETO токена
  static BackupFooterMetadata? fromFooter(String? footer) {
    if (footer == null) return null;
    try {
      final json = jsonDecode(footer);
      return BackupFooterMetadata.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
