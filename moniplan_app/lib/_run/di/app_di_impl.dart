// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:moniplan_app/_run/db/_index.dart';
import 'package:moniplan_app/core/config/env.dart';
import 'package:moniplan_app/core/services/tflite_category_predictor.dart';
import 'package:moniplan_app/features/license/repository/moniplan_license_repository.dart';
import 'package:moniplan_app/features/license/repository/secure_license_storage.dart';
import 'package:moniplan_app/features/monisync/repo/monisync_repo_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/planner/_index.dart';
import 'package:moniplan_app/features/statistic/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

class GetItAppDI implements AppDi {
  final _getIt = GetIt.instance;

  @override
  Future<void> setup() async {
    AppDb.factory = () => AppDbImpl();
    final db = AppDb();
    await db.openDefault();

    _getIt.registerSingleton<AppDb>(db);
    _getIt.registerSingleton<IPlannerRepo>(PlannerRepoDrift(appDb: db));
    _getIt.registerSingleton<IMonisyncRepo>(
      MonisyncRepoImpl(appDb: db, encryptKey: SecureEnv.dbEncryptionKey ?? ''),
    );
    _getIt.registerSingleton<IStatisticsRepo>(StatisticsRepoImpl(plannerRepo: getPlannerRepo()));

    // Регистрируем сервис категоризации платежей
    final paymentCategorizerService = PaymentCategorizerService();

    // Регистрируем предиктор категорий
    _getIt.registerSingleton<ICategoryPredictor>(
      TFLiteCategoryPredictor(paymentCategorizerService),
    );

    // Регистрируем генератор инсайтов
    _getIt.registerSingleton<IInsightGenerator>(
      InsightGeneratorImpl(categoryPredictor: _getIt.get<ICategoryPredictor>()),
    );

    _getIt.registerSingleton<IMoniplanLicenseRepo>(
      MoniplanLicenseRepository(
        licenseStorage: SecureLicenseStorage(FlutterSecureStorage()),
        licenseValidator: LicenseValidator(
          publicKey: utf8.decode(base64Decode(SecureEnv.publicKey)),
        ),
      ),
    );

    // Инициализируем сервис категоризации платежей
    paymentCategorizerService.initialize().catchError((e) {
      print('Ошибка инициализации PaymentCategorizerService: $e');
    });
  }

  @override
  AppDb getDb() => _getIt.get();

  @override
  IPlannerRepo getPlannerRepo() => _getIt.get();

  @override
  IMonisyncRepo getMonisyncRepo() => _getIt.get();

  @override
  IStatisticsRepo getStatisticsRepo() => _getIt.get();

  @override
  IInsightGenerator getInsightGenerator() => _getIt.get();

  @override
  ICategoryPredictor getPaymentCategorizer() => _getIt.get();

  @override
  IMoniplanLicenseRepo getLicenseRepo() => _getIt.get();

  @override
  T get<T extends Object>() => _getIt.get<T>();
}
