import 'package:intl/intl.dart';

import 'input_formatters.dart';

export 'bottom_sheet.dart';
export 'buttons.dart';
export 'confirm_dialog_builder.dart';
export 'dashboard_layout.dart';
export 'input_formatters.dart';
export 'inputs.dart';
export 'money_colored_widget.dart';

final dateFormat = DateFormat(DateFormat.MONTH_DAY, 'ru');

final moneyInputFormatter = CurrencyTextInputFormatter(
  decimalDigits: 2,
  allowNegative: true,
);
