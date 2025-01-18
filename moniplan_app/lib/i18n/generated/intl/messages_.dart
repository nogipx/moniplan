// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a  locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => '';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "moniplan_commonCancel": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_commonCompleted": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_commonDelete": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_commonDisabled": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_commonDuplicate": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_commonEnabled": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_commonFixate": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_commonNotcompleted": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_db_lastUpdated": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_entity_paymentPlural":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_entity_paymentSingle":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_entity_plannerPlural":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_entity_plannerSingle":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_modulesMoniplan": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_modulesMonisync": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_monisync_export_buttonaction":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_monisync_export_error":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_monisync_import_buttonaction":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_monisync_import_error":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_payments_actions_create":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_payments_actions_delete":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_payments_actions_update":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_payments_error_doneWithRepeat":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_payments_error_requiredDate":
            MessageLookupByLibrary.simpleMessage("Нужна дата"),
        "moniplan_planner_list_lastComputed":
            MessageLookupByLibrary.simpleMessage(""),
        "moniplan_stats_errorLoading": MessageLookupByLibrary.simpleMessage(""),
        "moniplan_title": MessageLookupByLibrary.simpleMessage("")
      };
}
