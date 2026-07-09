import 'package:get_it/get_it.dart';
import 'package:moniplan_app/database/_index.dart';
import 'package:moniplan_app/features/goals/repo/i_savings_goals_repo.dart';
import 'package:moniplan_app/features/goals/repo/savings_goals_repo_data_service.dart';
import 'package:moniplan_app/features/monisync/_index.dart';
import 'package:moniplan_app/features/monisync/repo/i_manual_monisync_repo.dart';
import 'package:moniplan_app/features/planner/repo/_index.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

abstract interface class IAppDi {
  Future<void> setup();

  IAppDb getDb();

  IDataService getDataService();

  IPlannersRepo getPlannersRepo();
  IPaymentsRepo getPaymentsRepo();
  IPlannerActualInfoRepo getPlannerActualInfoRepo();
  IPlannerSettingsRepo getPlannerSettingsRepo();
  ISavingsGoalsRepo getSavingsGoalsRepo();

  Future<IMonisyncRepo> getMonisyncRepo();
}

abstract class AppDi implements IAppDi {
  static late final AppDi instance;
}

class GetItAppDI implements AppDi {
  final _getIt = GetIt.instance;

  @override
  Future<void> setup() async {
    final db = AppDbImpl(log: RpcLogger('AppDbImpl'));
    _getIt.registerSingleton<IAppDb>(db, dispose: (impl) => impl.close());
    await db.open();

    final dataService = db.dataService;
    final plannersRepo = PlannersRepoDataService(dataService: dataService);
    final paymentsRepo = PaymentsRepoDataService(dataService: dataService);
    final actualInfoRepo = PlannerActualInfoRepoDataService(
      dataService: dataService,
    );
    final settingsRepo = PlannerSettingsRepoDataService(
      dataService: dataService,
    );
    final savingsGoalsRepo = SavingsGoalsRepoDataService(
      dataService: dataService,
    );
    _getIt
      ..registerSingleton<IDataService>(dataService)
      ..registerSingleton<IPlannersRepo>(plannersRepo)
      ..registerSingleton<IPaymentsRepo>(paymentsRepo)
      ..registerSingleton<IPlannerActualInfoRepo>(actualInfoRepo)
      ..registerSingleton<IPlannerSettingsRepo>(settingsRepo)
      ..registerSingleton<ISavingsGoalsRepo>(savingsGoalsRepo)
      ..registerSingletonAsync<PackageInfo>(PackageInfo.fromPlatform)
      ..registerFactoryAsync<IMonisyncRepo>(() async {
        return MonisyncRepoImpl(dataService: dataService);
      });
  }

  @override
  IAppDb getDb() => _getIt.get();

  @override
  IDataService getDataService() => _getIt.get();

  @override
  IPlannersRepo getPlannersRepo() => _getIt.get();

  @override
  IPaymentsRepo getPaymentsRepo() => _getIt.get();

  @override
  IPlannerActualInfoRepo getPlannerActualInfoRepo() => _getIt.get();

  @override
  IPlannerSettingsRepo getPlannerSettingsRepo() => _getIt.get();

  @override
  ISavingsGoalsRepo getSavingsGoalsRepo() => _getIt.get();

  @override
  Future<IMonisyncRepo> getMonisyncRepo() async {
    return _getIt.getAsync<IMonisyncRepo>();
  }
}
