// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  static const _reopenWaitDuration = Duration(milliseconds: 500);

  StreamSubscription? _listenChanges;
  AppLog? _log;

  @override
  MoniplanDriftDb get db => _db!;
  MoniplanDriftDb? _db;

  final SqliteFileProvider _dbFileProvider;
  final bool _inMemory;

  AppDbImpl._(this._dbFileProvider, this._log, this._inMemory);

  factory AppDbImpl(SqliteFileProvider dbFileProvider, {AppLog? log, bool inMemory = false}) {
    return AppDbImpl._(dbFileProvider, log ?? AppLog('AppDbImpl'), inMemory);
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
  Future<void> open() async {
    try {
      await close();
      await Future.delayed(_reopenWaitDuration);

      if (_inMemory) {
        final bytes = await _dbFileProvider().then((value) => value.readAsBytes());
        final executor = await driftOpenInMemory(bytes);
        _db = MoniplanDriftDb(dbExecutor: executor);
      } else {
        final executor = await driftOpen(_dbFileProvider);
        _db = MoniplanDriftDb(dbExecutor: executor);
      }

      _startWatchChanges();

      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('open', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<void> overwriteWithBytes({required Uint8List bytes}) async {
    try {
      await close();
      await Future.delayed(_reopenWaitDuration);

      final newBytes = bytes;

      final dbFile = await _dbFileProvider();
      await dbFile.writeAsBytes(newBytes);

      await open();
    } on Object catch (error, trace) {
      _log?.critical('overwriteWithBytes', error: error, trace: trace);
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

  @override
  Future<String> getPath() async {
    final file = await _dbFileProvider();
    return file.path;
  }
}
