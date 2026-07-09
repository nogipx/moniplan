/// Pure Dart payroll engine: vacation pay and dismissal compensation (RF).
///
/// Knows nothing about moniplan's `Payment`. Produces its own result models;
/// mapping to `Payment` lives in the app feature.
library;

export 'src/models/enums.dart';
export 'src/models/errors.dart';
export 'src/models/earnings.dart';
export 'src/models/income_profile.dart';
export 'src/models/payroll_request.dart';
export 'src/models/payroll_result.dart';
export 'src/reference/ndfl_scale.dart';
export 'src/reference/production_calendar.dart';
export 'src/reference/mrot_history.dart';
export 'src/reference/key_rate_history.dart';
export 'src/engine/money.dart';
export 'src/engine/payroll_engine.dart';
