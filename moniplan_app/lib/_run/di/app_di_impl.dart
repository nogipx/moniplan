// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:moniplan_app/_run/db/_index.dart';
import 'package:moniplan_app/_run/di/di_utils.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monisync/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/statistic/_index.dart';
import 'package:moniplan_app/domain/lib/moniplan_domain.dart';
import 'package:moniplan_app/domain/lib/moniplan_domain.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GetItAppDI implements AppDi {
  final _getIt = GetIt.instance;

  @override
  Future<void> setup() async {
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
  IMoniplanLicenseRepo getLicenseRepo() => _getIt.get();

  @override
  IFeaturesManager getFeaturesManager() => _getIt.get();

  @override
  T get<T extends Object>() => _getIt.get<T>();

  @override
  Future<IAppEncrypter> getEncrypter([AppEncrypterFactoryArgs? args]) async {
    return _getIt.getAsync<IAppEncrypter>(param1: args ?? AppEncrypterFactoryArgs());
  }
}
