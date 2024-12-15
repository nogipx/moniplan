// GENERATED CODE - DO NOT MODIFY BY HAND (keys_generator)
// SOURCE YAML - package:moniplan_domain/i18n/moniplan.keys.yml
// ignore_for_file: library_private_types_in_public_api

/// Ключи приложения Moniplan
class MoniplanKeys {
  const MoniplanKeys._();
  static const MoniplanKeys i = MoniplanKeys._();

  /// Название приложения
  String get title => 'moniplan.title';

  /// Скоуп ключей для платежей
  _MoniplanPaymentsKeys get payments => const _MoniplanPaymentsKeys._();

  /// Скоуп ключей для планнеров
  _MoniplanPlannerKeys get planner => const _MoniplanPlannerKeys._();
  _MoniplanStatsKeys get stats => const _MoniplanStatsKeys._();
  _MoniplanDbKeys get db => const _MoniplanDbKeys._();
}

class _MoniplanDbKeys {
  const _MoniplanDbKeys._();

  /// Когда в последний раз обновлена бд
  String get lastUpdated => 'moniplan.db.lastUpdated';
}

class _MoniplanStatsKeys {
  const _MoniplanStatsKeys._();
  _MoniplanStatsErrorKeys get error => const _MoniplanStatsErrorKeys._();
}

class _MoniplanStatsErrorKeys {
  const _MoniplanStatsErrorKeys._();
  String get loading => 'moniplan.stats.error.loading';
}

/// Скоуп ключей для планнеров
class _MoniplanPlannerKeys {
  const _MoniplanPlannerKeys._();
  _MoniplanPlannerListKeys get list => const _MoniplanPlannerListKeys._();
}

class _MoniplanPlannerListKeys {
  const _MoniplanPlannerListKeys._();

  /// Когда в последний раз подсчитан планер
  String get lastComputed => 'moniplan.planner.list.lastComputed';
}

/// Скоуп ключей для платежей
class _MoniplanPaymentsKeys {
  const _MoniplanPaymentsKeys._();
  _MoniplanPaymentsSomeSnakeGroupKeys get someSnakeGroup => const _MoniplanPaymentsSomeSnakeGroupKeys._();
  _MoniplanPaymentsErrorKeys get error => const _MoniplanPaymentsErrorKeys._();
}

class _MoniplanPaymentsErrorKeys {
  const _MoniplanPaymentsErrorKeys._();

  /// Нужно ввести дату
  String get requiredDate => 'moniplan.payments.error.requiredDate';

  /// Ошибка, нельзя отметить выполненным повторяющийся платеж
  String get doneWithRepeat => 'moniplan.payments.error.doneWithRepeat';
}

class _MoniplanPaymentsSomeSnakeGroupKeys {
  const _MoniplanPaymentsSomeSnakeGroupKeys._();
  String get test1 => 'moniplan.payments.someSnakeGroup.test1';
  String get test2 => 'moniplan.payments.someSnakeGroup.test2';
}

