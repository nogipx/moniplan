// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:get_it/get_it.dart';
import 'package:moniplan_app/_run/db/_index.dart';
import 'package:moniplan_app/features/monisync/repo/monisync_repo_impl.dart';
import 'package:moniplan_core/moniplan_core.dart';

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
    _getIt.registerSingleton<IMonisyncRepo>(MonisyncRepoImpl(
      appDb: db,
      encryptKey: mockEncryptionKey,
    ));
  }

  @override
  AppDb getDb() => _getIt.get();
  @override
  IPlannerRepo getPlannerRepo() => _getIt.get();
  @override
  IMonisyncRepo getMonisyncRepo() => _getIt.get();
}
