import 'package:intl/intl.dart';
import 'package:moniplan/common/export.dart';

export 'badge.dart';
export 'bottom_sheet.dart';
export 'buttons.dart';
export 'confirm_dialog_builder.dart';
export 'input_formatters.dart';
export 'inputs.dart';
export 'money_colored_widget.dart';

final dateFormat = DateFormat(DateFormat.MONTH_DAY, 'ru');
final dateFormatYear = DateFormat(DateFormat.YEAR_MONTH_DAY, 'ru');

final moneyInputFormatter = CurrencyTextInputFormatter(
  decimalDigits: 2,
);
