// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:get_it/get_it.dart';
import 'package:moniplan_app/_run/db/_index.dart';
import 'package:moniplan_app/core/services/tflite_category_predictor.dart';
import 'package:moniplan_app/features/monisync/repo/monisync_repo_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/planner/_index.dart';
import 'package:moniplan_app/features/statistic/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

const mockEncryptionKey = 'J33L06KoJbO1okTNJ1sHNV1DS5UiVtLPLmWn0RZbxGk=';

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
      MonisyncRepoImpl(appDb: db, encryptKey: mockEncryptionKey),
    );
    _getIt.registerSingleton<IStatisticsRepo>(StatisticsRepoImpl(plannerRepo: getPlannerRepo()));
    _getIt.registerSingleton<IInsightGenerator>(InsightGeneratorImpl());

    // Регистрируем сервис категоризации платежей
    final paymentCategorizerService = PaymentCategorizerService();

    _getIt.registerSingleton<ICategoryPredictor>(
      TFLiteCategoryPredictor(paymentCategorizerService),
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
  T get<T extends Object>() => _getIt.get<T>();
}
