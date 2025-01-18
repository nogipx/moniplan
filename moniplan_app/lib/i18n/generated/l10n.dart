// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// ``
  String get moniplan_title {
    return Intl.message(
      '',
      name: 'moniplan_title',
      desc: 'Название приложения',
      args: [],
    );
  }

  /// `Date required`
  String get moniplan_payments_error_requiredDate {
    return Intl.message(
      'Date required',
      name: 'moniplan_payments_error_requiredDate',
      desc: 'Нужно ввести дату',
      args: [],
    );
  }

  /// ``
  String get moniplan_payments_error_doneWithRepeat {
    return Intl.message(
      '',
      name: 'moniplan_payments_error_doneWithRepeat',
      desc: 'Ошибка, нельзя отметить выполненным повторяющийся платеж',
      args: [],
    );
  }

  /// ``
  String get moniplan_planner_list_lastComputed {
    return Intl.message(
      '',
      name: 'moniplan_planner_list_lastComputed',
      desc: 'Когда в последний раз подсчитан планер',
      args: [],
    );
  }

  /// ``
  String get moniplan_stats_errorLoading {
    return Intl.message(
      '',
      name: 'moniplan_stats_errorLoading',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_db_lastUpdated {
    return Intl.message(
      '',
      name: 'moniplan_db_lastUpdated',
      desc: 'Когда в последний раз обновлена бд',
      args: [],
    );
  }

  /// ``
  String get moniplan_modulesMoniplan {
    return Intl.message(
      '',
      name: 'moniplan_modulesMoniplan',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_modulesMonisync {
    return Intl.message(
      '',
      name: 'moniplan_modulesMonisync',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_commonCancel {
    return Intl.message(
      '',
      name: 'moniplan_commonCancel',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_commonDelete {
    return Intl.message(
      '',
      name: 'moniplan_commonDelete',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_commonDuplicate {
    return Intl.message(
      '',
      name: 'moniplan_commonDuplicate',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_commonFixate {
    return Intl.message(
      '',
      name: 'moniplan_commonFixate',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_commonEnabled {
    return Intl.message(
      '',
      name: 'moniplan_commonEnabled',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_commonDisabled {
    return Intl.message(
      '',
      name: 'moniplan_commonDisabled',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_commonCompleted {
    return Intl.message(
      '',
      name: 'moniplan_commonCompleted',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_commonNotcompleted {
    return Intl.message(
      '',
      name: 'moniplan_commonNotcompleted',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_entity_plannerSingle {
    return Intl.message(
      '',
      name: 'moniplan_entity_plannerSingle',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_entity_plannerPlural {
    return Intl.message(
      '',
      name: 'moniplan_entity_plannerPlural',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_entity_paymentSingle {
    return Intl.message(
      '',
      name: 'moniplan_entity_paymentSingle',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_entity_paymentPlural {
    return Intl.message(
      '',
      name: 'moniplan_entity_paymentPlural',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_payments_actions_create {
    return Intl.message(
      '',
      name: 'moniplan_payments_actions_create',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_payments_actions_update {
    return Intl.message(
      '',
      name: 'moniplan_payments_actions_update',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_payments_actions_delete {
    return Intl.message(
      '',
      name: 'moniplan_payments_actions_delete',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_monisync_export_buttonaction {
    return Intl.message(
      '',
      name: 'moniplan_monisync_export_buttonaction',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_monisync_export_error {
    return Intl.message(
      '',
      name: 'moniplan_monisync_export_error',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_monisync_import_buttonaction {
    return Intl.message(
      '',
      name: 'moniplan_monisync_import_buttonaction',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get moniplan_monisync_import_error {
    return Intl.message(
      '',
      name: 'moniplan_monisync_import_error',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
