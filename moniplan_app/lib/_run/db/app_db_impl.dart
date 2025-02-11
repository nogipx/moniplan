// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_app/_run/db/drift_open_temporary_connection.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/moniplan_db.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  static AppDbImpl? _instance;
  static AppLog? _log;
  static const _reopenWaitDuration = Duration(milliseconds: 500);

  MoniplanDriftDb? _db;
  StreamSubscription? _listenChanges;

  @override
  MoniplanDriftDb get db => _db!;

  AppDbImpl._();

  factory AppDbImpl() {
    _log ??= AppLog('AppDbImpl');
    if (_instance != null) {
      return _instance!;
    }
    _instance = AppDbImpl._();
    return _instance!;
  }

  @override
  Future<void> close() async {
    try {
      await _db?.close();
      _stopWatchChanges();
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
      _startWatchChanges();

      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('openDefault', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<void> openTemporaryFromFile({
    required File dbFile,
    String encryptKey = '',
  }) async {
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

      if (encryptKey.isNotEmpty) {
        final encryptionHelper = EncryptionHelper(encryptKey);
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
  Future<void> overrideDefaultFromFile({
    required File newDbFile,
    String encryptKey = '',
  }) async {
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

      if (encryptKey.isNotEmpty) {
        final encryptionHelper = EncryptionHelper(encryptKey);
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

  Future<void> _updateLastActionDate() async {
    if (_db == null) {
      throw Exception('Database not opened');
    }

    final data = GlobalLastUpdateData(
      lastUpdateId: GlobalLastUpdate.entityId,
      updatedAt: DateTime.now(),
    );

    _db!.globalLastUpdate.insertOne(data, mode: InsertMode.insertOrReplace);
  }

  void _startWatchChanges() {
    if (_db == null) {
      throw Exception('Database not opened');
    }

    final query = TableUpdateQuery.onAllTables([
      _db!.paymentPlannersDriftTable,
      _db!.paymentsComposedDriftTable,
    ]);

    _listenChanges = _db!.tableUpdates(query).listen((updates) {
      _updateLastActionDate();
    });
  }

  void _stopWatchChanges() {
    _listenChanges?.cancel();
  }
}
