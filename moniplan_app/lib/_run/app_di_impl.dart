// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:get_it/get_it.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/domain/moniplan_domain.dart';
import 'package:moniplan_app/features/monisync/_index.dart';
import 'package:moniplan_app/features/monisync/repo/i_manual_monisync_repo.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/statistic/repo/i_statistics_repo.dart';
import 'package:moniplan_app/features/statistic/repo/statistics_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rpc_dart/logger.dart';

abstract interface class IAppDi {
  Future<void> setup();

  IAppDb getDb();

  IPlannerRepo getPlannerRepo();

  Future<IMonisyncRepo> getMonisyncRepo();

  IStatisticsRepo getStatisticsRepo();

  IMoniplanLicenseRepo getLicenseRepo();

  IFeaturesManager getFeaturesManager();
}

abstract class AppDi implements IAppDi {
  static late final AppDi instance;

  @override
  AppDb getDb();

  T get<T extends Object>();
}

class GetItAppDI implements AppDi {
  final _getIt = GetIt.instance;

  @override
  Future<void> setup() async {
    final dbImpl = AppDbImpl(log: RpcLogger('AppDbImpl'));
    _getIt.registerSingleton<AppDbImpl>(dbImpl, dispose: (impl) => impl.close());

    AppDb.factory = () => GetIt.instance.get<AppDbImpl>();
    final db = AppDb();
    await db.open();
    _getIt.registerSingleton<AppDb>(db);
    _getIt.registerSingleton<IMoniplanLicenseRepo>(MockLicenseRepository());

    _getIt.registerSingletonAsync<PackageInfo>(PackageInfo.fromPlatform);
    _getIt.registerSingleton<IPlannerRepo>(PlannerRepoDrift(appDb: dbImpl));

    _getIt.registerFactoryAsync<IMonisyncRepo>(() async {
      return MonisyncRepoImpl(appDb: db);
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
}
