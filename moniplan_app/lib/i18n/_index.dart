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
