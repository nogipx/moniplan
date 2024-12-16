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
