import 'package:get_it/get_it.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/features/monisync/_index.dart';
import 'package:moniplan_app/features/monisync/repo/i_manual_monisync_repo.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/statistic/repo/i_statistics_repo.dart';
import 'package:moniplan_app/features/statistic/repo/statistics_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

abstract interface class IAppDi {
  Future<void> setup();

  IAppDb getDb();

  IDataService getDataService();

  IPlannerRepo getPlannerRepo();

  Future<IMonisyncRepo> getMonisyncRepo();

  IStatisticsRepo getStatisticsRepo();
}

abstract class AppDi implements IAppDi {
  static late final AppDi instance;

  @override
  IAppDb getDb();

  @override
  IDataService getDataService();
}

class GetItAppDI implements AppDi {
  final _getIt = GetIt.instance;

  @override
  Future<void> setup() async {
    final db = AppDbImpl(log: RpcLogger('AppDbImpl'));
    _getIt.registerSingleton<IAppDb>(db, dispose: (impl) => impl.close());
    await db.open();

    final dataService = db.dataService;
    _getIt
      ..registerSingleton<IDataService>(dataService)
      ..registerSingletonAsync<PackageInfo>(PackageInfo.fromPlatform)
      ..registerSingleton<IPlannerRepo>(PlannerRepoDataService(dataService: dataService))
      ..registerFactoryAsync<IMonisyncRepo>(() async {
        return MonisyncRepoImpl(dataService: dataService);
      })
      ..registerSingleton<IStatisticsRepo>(StatisticsRepoImpl(plannerRepo: getPlannerRepo()));
  }

  @override
  IAppDb getDb() => _getIt.get();

  @override
  IDataService getDataService() => _getIt.get();

  @override
  IPlannerRepo getPlannerRepo() => _getIt.get();

  @override
  Future<IMonisyncRepo> getMonisyncRepo() async {
    return _getIt.getAsync<IMonisyncRepo>();
  }

  @override
  IStatisticsRepo getStatisticsRepo() => _getIt.get();
}
