import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:moniplan/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/sdk/hive/hive_setup.dart';
import 'package:moniplan/sdk/service/operation_service.dart';
import 'package:moniplan/service/budget_event_service_hive.dart';

FutureProvider<Box<T>> openBoxProvider<T>(String boxName) =>
    FutureProvider((ref) {
      return Hive.openBox<T>(boxName).then((value) {
        ref.onDispose(() {
          value.close();
        });
        return value;
      });
    });

final _operationHive = openBoxProvider<Operation>(OperationService.key);
final _operationService = Provider<OperationService>((ref) {
  return OperationServiceHive(hive: hive);
});

final predictionCubitProvider = StateNotifierProvider(
  (ref) {
    return BudgetPredictionCubit(
      operationService: ref.read(_operationService),
    );
  },
  dependencies: [
    _operationHive,
  ],
);

late final _hiveInstance = HiveInstance()..init();
final hiveProvider = Provider<HiveInstance>((ref) => _hiveInstance);
