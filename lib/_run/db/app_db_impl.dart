import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:moniplan/_run/_index.dart';
import 'package:moniplan/_run/db/drift_open_temporary_connection.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/moniplan_db.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  static AppDbImpl? _instance;
  static AppLog? _log;
  static const _reopenWaitDuration = Duration(milliseconds: 500);

  MoniplanDriftDb? _db;
  String? _encryptKey;

  @override
  MoniplanDriftDb get value => _db!;

  AppDbImpl._(this._encryptKey);

  factory AppDbImpl({
    String? encryptKey,
  }) {
    _log ??= AppLog('AppDbImpl');
    if (_instance != null) {
      return _instance!;
    }
    _instance = AppDbImpl._(encryptKey);
    return _instance!;
  }

  @override
  Future<void> close() async {
    try {
      await _db?.close();
      await driftClearTemporary();
      _db = null;
      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('close', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<void> openDefault() async {
    try {
      await close();
      await Future.delayed(_reopenWaitDuration);
      final executor = await driftOpenDefault();
      _db = MoniplanDriftDb(dbExecutor: executor);

      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('openDefault', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<void> openFromFile(File dbFile) async {
    try {
      final cleanedPath = dbFile.path.replaceAll('file://', '');
      final file = File(cleanedPath);
      if (!file.existsSync()) {
        throw Exception('File $dbFile not found.');
      }
      await close();
      await Future.delayed(_reopenWaitDuration);

      final newBytes = await file.readAsBytes();
      Uint8List tempBytes = newBytes;

      if (_encryptKey != null && _encryptKey!.isNotEmpty) {
        final encryptionHelper = EncryptionHelper(_encryptKey!);
        tempBytes = encryptionHelper.decryptBytes(newBytes);
      }

      final connection = driftOpenTemporary(bytes: tempBytes);

      final tempDb = MoniplanDriftDb(
        dbExecutor: connection,
      );
      _db = tempDb;
      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('openFromFile', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<void> overrideDefaultFromFile(File newDbFile) async {
    try {
      final cleanedPath = newDbFile.path.replaceAll('file://', '');
      final file = File(cleanedPath);
      if (!file.existsSync()) {
        throw Exception('File $newDbFile not found.');
      }
      await close();
      await Future.delayed(_reopenWaitDuration);

      final newBytes = await file.readAsBytes();
      Uint8List tempBytes = newBytes;

      if (_encryptKey != null && _encryptKey!.isNotEmpty) {
        final encryptionHelper = EncryptionHelper(_encryptKey!);
        tempBytes = encryptionHelper.decryptBytes(newBytes);
      }

      final dbFile = await getDatabaseFile();
      await dbFile.writeAsBytes(tempBytes);

      await openDefault();
    } on Object catch (error, trace) {
      _log?.critical('overrideDefaultFromFile', error: error, trace: trace);
      rethrow;
    }
  }
}
