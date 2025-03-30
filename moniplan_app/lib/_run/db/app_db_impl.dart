// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_app/_run/db/drift_open_temporary_connection.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monisync/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

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
  Future<void> openTemporaryFromFile({required File dbFile, String keyBase64 = ''}) async {
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

      if (keyBase64.isNotEmpty) {
        // Проверяем наличие маркера зашифрованного файла
        const markerText = 'ENCRYPTED:';
        final markerBytes = markerText.codeUnits;

        int ivOffset = 0;
        if (newBytes.length > markerBytes.length) {
          final possibleMarker = newBytes.sublist(0, markerBytes.length);
          final markerString = String.fromCharCodes(possibleMarker);

          if (markerString == markerText) {
            ivOffset = markerBytes.length;
          }
        }

        // Извлекаем IV из файла после маркера (если он есть)
        final ivBytes = newBytes.sublist(ivOffset, ivOffset + 8);
        final iv = encrypt.IV(ivBytes);
        final encryptedData = newBytes.sublist(ivOffset + 8);

        final encryptionHelper = AesMonisyncEncrypter(keyBase64);
        tempBytes = encryptionHelper.decryptBytes(encryptedData, options: {'iv': iv});
      }

      final connection = driftOpenTemporary(bytes: tempBytes);

      final tempDb = MoniplanDriftDb(dbExecutor: connection);
      _db = tempDb;

      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('openFromFile', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<void> overrideDefaultFromFile({required File newDbFile, String keyBase64 = ''}) async {
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

      if (keyBase64.isNotEmpty) {
        // final encryptionHelper = AesMonisyncEncrypter(keyBase64);
        // tempBytes = encryptionHelper.decryptBytes(newBytes);
        // Проверяем наличие маркера зашифрованного файла
        const markerText = 'ENCRYPTED:';
        final markerBytes = markerText.codeUnits;

        int ivOffset = 0;
        if (newBytes.length > markerBytes.length) {
          final possibleMarker = newBytes.sublist(0, markerBytes.length);
          final markerString = String.fromCharCodes(possibleMarker);

          if (markerString == markerText) {
            ivOffset = markerBytes.length;
          }
        }

        // Извлекаем IV из файла после маркера (если он есть)
        final ivBytes = newBytes.sublist(ivOffset, ivOffset + 8);
        final iv = encrypt.IV(ivBytes);
        final encryptedData = newBytes.sublist(ivOffset + 8);

        final helper = Salsa20MonisyncEncrypter(
          encrypter: encrypt.Encrypter(encrypt.Salsa20(encrypt.Key.fromBase64(keyBase64))),
        );
        tempBytes = helper.decryptBytes(encryptedData, options: {'iv': iv});
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
