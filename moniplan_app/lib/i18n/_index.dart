// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:intl/intl.dart';

export 'package:intl/intl.dart';

export 'generated/intl/messages_all.dart';
export 'generated/l10n.dart';

extension IntlExt on String {
  String get intl {
    return Intl.message(
      '',
      name: this,
      desc: '',
      args: [],
    );
  }
}
