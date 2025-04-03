// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:moniplan_app/_run/db/_index.dart';
import 'package:moniplan_app/_run/di/di_utils.dart';
import 'package:moniplan_app/core/services/tflite_category_predictor.dart';
import 'package:moniplan_app/features/license/repository/moniplan_license_repository.dart';
import 'package:moniplan_app/features/license/repository/secure_license_storage.dart';
import 'package:moniplan_app/features/license/services/device_info_provider.dart';
import 'package:moniplan_app/features/monisync/_index.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/planner/_index.dart';
import 'package:moniplan_app/features/statistic/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:package_info_plus/package_info_plus.dart';

const mockEncryptionKey = 'J33L06KoJbO1okTNJ1sHNV1DS5UiVtLPLmWn0RZbxGk=';
const mockPublicKey = 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiAKBgHCO7QY5Z+Q+';

class GetItAppDI implements AppDi {
  final _getIt = GetIt.instance;

  @override
  Future<void> setup() async {
    final publicKey = LicensifyKeyImporter.importPublicKeyFromString(
      utf8.decode(base64.decode(SecureEnv.publicKey)),
    );

    final dbImpl = AppDbImpl(getDatabaseFile, log: AppLog('AppDbImpl'));
    _getIt.registerSingleton<AppDbImpl>(dbImpl, dispose: (impl) => impl.close());

    AppDb.factory = () => GetIt.instance.get<AppDbImpl>();
    final db = AppDb();
    await db.open();
    _getIt.registerSingleton<AppDb>(db);

    _getIt.registerSingletonAsync<PackageInfo>(PackageInfo.fromPlatform);
    _getIt.registerSingleton<IPlannerRepo>(PlannerRepoDrift(appDb: dbImpl));

    _getIt.registerFactoryParamAsync<IAppEncrypter, AppEncrypterFactoryArgs, dynamic>(
      encrypterFactory,
    );

    _getIt.registerFactoryAsync<IMonisyncRepo>(() async {
      final encrypter = await AppDi.instance.getEncrypter();
      return MonisyncRepoImpl(appDb: db, encrypter: encrypter);
    });
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

    // Регистрируем репозиторий лицензий
    final licenseRepo = MoniplanLicenseRepository(
      licenseStorage: SecureLicenseStorage(FlutterSecureStorage()),
      licenseValidator: publicKey.licenseValidator,
      licenseRequestGenerator: publicKey.licenseRequestGenerator(),
      deviceHashGenerator: DeviceHashGenerator(
        deviceInfoProvider: DeviceInfoProvider().getDeviceInfo,
      ),
    );
    _getIt.registerSingleton<IMoniplanLicenseRepo>(licenseRepo);

    // Регистрируем сервис лицензионных функций
    final licenseFeaturesService = LicenseFeaturesService(licenseRepo);
    _getIt.registerSingleton<LicenseFeaturesService>(licenseFeaturesService);

    // Инициализируем сервис лицензионных функций
    licenseFeaturesService.initialize().catchError((e) {
      print('Ошибка инициализации LicenseFeaturesService: $e');
    });

    // Инициализируем менеджер фичей
    _getIt.registerSingleton<MoniplanFeaturesManager>(
      MoniplanFeaturesManager(licenseFeaturesService: licenseFeaturesService)
        ..forceReloadFeatures(),
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
  Future<IMonisyncRepo> getMonisyncRepo() async {
    return _getIt.getAsync<IMonisyncRepo>();
  }

  @override
  IStatisticsRepo getStatisticsRepo() => _getIt.get();

  @override
  IInsightGenerator getInsightGenerator() => _getIt.get();

  @override
  ICategoryPredictor getPaymentCategorizer() => _getIt.get();

  @override
  IMoniplanLicenseRepo getLicenseRepo() => _getIt.get();

  @override
  LicenseFeaturesService getLicenseFeaturesService() => _getIt.get();

  @override
  MoniplanFeaturesManager getFeaturesManager() => _getIt.get();

  @override
  T get<T extends Object>() => _getIt.get<T>();

  @override
  Future<IAppEncrypter> getEncrypter([AppEncrypterFactoryArgs? args]) async {
    return _getIt.getAsync<IAppEncrypter>(param1: args ?? AppEncrypterFactoryArgs());
  }
}
